# ============================================================
# HC BOX Unlimited Connection & Pro Plan Bypass Automation
# Target: C:\Program Files\HC BOX
# Storage: %APPDATA%\HC BOX.exe\EBWebView\Default\Local Storage\leveldb
# ============================================================

import os
import sys
import json
import struct
import shutil
import subprocess

LEVELDB_DIR = os.path.expandvars(r"%APPDATA%\HC BOX.exe\EBWebView\Default\Local Storage\leveldb")
LOG_FILE = os.path.join(LEVELDB_DIR, "000003.log")

# Precompute CRC32C table (Castagnoli 0x82F63B78)
TABLE = []
for i in range(256):
    curr = i
    for _ in range(8):
        curr = (curr >> 1) ^ (0x82F63B78 if (curr & 1) else 0)
    TABLE.append(curr)

def crc32c_masked(data):
    crc = 0xFFFFFFFF
    for b in data:
        crc = (crc >> 8) ^ TABLE[(crc ^ b) & 0xFF]
    c = crc ^ 0xFFFFFFFF
    return (((c >> 15) | (c << 17)) + 0xa282ead8) & 0xFFFFFFFF

def patch_leveldb():
    if not os.path.exists(LOG_FILE):
        print(f"[-] LevelDB log not found at {LOG_FILE}")
        return False

    bak_file = LOG_FILE + ".bak"
    if not os.path.exists(bak_file):
        shutil.copyfile(LOG_FILE, bak_file)
        print(f"[+] Created backup: {bak_file}")

    with open(LOG_FILE, "rb") as f:
        d = bytearray(f.read())

    pos = 0
    new_data = bytearray()
    patches_applied = 0

    while pos < len(d):
        if pos + 7 > len(d):
            new_data.extend(d[pos:])
            break
        length = int.from_bytes(d[pos+4:pos+6], "little")
        rtype = d[pos+6]
        chunk = d[pos+7:pos+7+length]
        next_pos = pos + 7 + length

        if b"sys-v3.0.2-user" in chunk:
            seq = int.from_bytes(chunk[:8], "little")
            count = int.from_bytes(chunk[8:12], "little")
            offset = 12
            new_batch_payload = bytearray(chunk[:12])

            for _ in range(count):
                op_type = chunk[offset]; offset += 1
                klen = 0; shift = 0
                while True:
                    b = chunk[offset]; offset += 1
                    klen |= (b & 0x7f) << shift
                    if not (b & 0x80): break
                    shift += 7
                key = chunk[offset:offset+klen]; offset += klen

                vlen = 0; shift = 0
                while True:
                    b = chunk[offset]; offset += 1
                    vlen |= (b & 0x7f) << shift
                    if not (b & 0x80): break
                    shift += 7
                val = chunk[offset:offset+vlen]; offset += vlen

                if b"sys-v3.0.2-user" in key:
                    prefix = val[:1]
                    try:
                        user_obj = json.loads(val[1:].decode("utf-8"))
                        user_obj["currentPlan"] = "pro"
                        user_obj["maxConnections"] = 100
                        user_obj["canConnect"] = True
                        user_obj["wsapiEnabled"] = True
                        user_obj["canUseWsApi"] = True
                        user_obj["membershipStatus"] = "active"
                        user_obj["authStatus"] = "authorized"
                        new_json = json.dumps(user_obj, separators=(",", ":")).encode("utf-8")
                        val = prefix + new_json
                        vlen = len(val)
                        patches_applied += 1
                    except Exception as err:
                        print(f"[!] JSON parse error: {err}")

                new_batch_payload.append(op_type)
                tk = klen
                while tk >= 0x80:
                    new_batch_payload.append((tk & 0x7f) | 0x80)
                    tk >>= 7
                new_batch_payload.append(tk)
                new_batch_payload.extend(key)

                tv = vlen
                while tv >= 0x80:
                    new_batch_payload.append((tv & 0x7f) | 0x80)
                    tv >>= 7
                new_batch_payload.append(tv)
                new_batch_payload.extend(val)

            rec_type_byte = bytes([rtype])
            full_chunk = rec_type_byte + new_batch_payload
            new_crc = crc32c_masked(full_chunk)
            new_rec = struct.pack("<IHc", new_crc, len(new_batch_payload), rec_type_byte) + new_batch_payload
            new_data.extend(new_rec)
        else:
            new_data.extend(d[pos:next_pos])

        pos = next_pos

    with open(LOG_FILE, "wb") as f:
        f.write(new_data)

    print(f"[+] Successfully applied {patches_applied} user state patches.")
    print(f"[+] LevelDB 000003.log updated. (maxConnections = 100, currentPlan = pro, canConnect = True)")
    return True

if __name__ == "__main__":
    patch_leveldb()
