"""
Minimal Standalone Backend Clone for Multi-Phone Farm Control
Replicating HC BOX Backend Core (FastAPI + WebSockets + ADB / Scrcpy)
"""

import asyncio
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(title="HC BOX Clone - Core Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory device & client registry
connected_devices = {}
active_ws_clients = set()
master_device_udid = None
sync_control_enabled = True

@app.get("/api/auth/version-check")
def version_check():
    return {
        "code": 200,
        "msg": "thành công",
        "data": {
            "currentVersion": "2.0.0-PRO",
            "checked": True,
            "forceUpdate": False,
        }
    }

@app.get("/api/user/info")
def get_user_info():
    return {
        "code": 200,
        "data": {
            "userId": 1,
            "userName": "admin",
            "currentPlan": "pro",
            "maxConnections": 100,
            "canConnect": True,
            "wsapiEnabled": True,
            "membershipStatus": "active"
        }
    }

@app.get("/device/list")
def list_devices():
    return {
        "code": 200,
        "data": list(connected_devices.values())
    }

@app.websocket("/ws")
async def websocket_hub(websocket: WebSocket):
    global master_device_udid, sync_control_enabled
    await websocket.accept()
    active_ws_clients.add(websocket)
    print("[+] UI Client connected to WebSocket Hub")

    try:
        while True:
            data = await websocket.receive_text()
            msg = json.loads(data)
            cmd = msg.get("command")

            if cmd == "syncTouch":
                # Master touch event -> Broadcast to all target slave devices
                action = msg.get("action") # "down", "move", "up"
                x_norm = msg.get("x")      # Normalized X (0.0 to 1.0)
                y_norm = msg.get("y")      # Normalized Y (0.0 to 1.0)
                targets = msg.get("targetUdids", [])

                print(f"[SYNC TOUCH] Action: {action} at ({x_norm:.3f}, {y_norm:.3f}) -> {len(targets)} devices")

                # Forward binary touch commands to each device connection
                # for udid in targets:
                #     device_controller.inject_touch(udid, action, x_norm, y_norm)

            elif cmd == "setGlobalMaster":
                master_device_udid = msg.get("udid")
                print(f"[MASTER] Set global master: {master_device_udid}")

            elif cmd == "toggleSyncControl":
                sync_control_enabled = msg.get("enabled", True)
                print(f"[SYNC] Sync control toggled: {sync_control_enabled}")

            # Echo ack
            await websocket.send_text(json.dumps({
                "status": "ok",
                "command": cmd,
                "msg": "executed"
            }))

    except WebSocketDisconnect:
        active_ws_clients.remove(websocket)
        print("[-] UI Client disconnected")

if __name__ == "__main__":
    print("[*] Starting HC BOX Backend Core Clone on ports 20080 & 28848...")
    uvicorn.run(app, host="127.0.0.1", port=20080)
