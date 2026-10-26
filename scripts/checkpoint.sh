#!/usr/bin/env bash
# ==============================================================================
# Agent Context Compaction & Checkpoint Generator (Bash)
# ==============================================================================
set -e

COMPLETED="$1"
NEXT_STEPS="$2"
BLOCKERS="${3:-None}"

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRATCHPAD="$SOURCE_DIR/docs/scratchpad.md"

NOW_STR=$(date "+%Y-%m-%d %H:%M:%S")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
GIT_STATUS=$(git status --short 2>/dev/null || echo "Working tree clean.")

cat << EOF > "$SCRATCHPAD"
# 📝 Live Session Scratchpad & Checkpoint

> **Last Updated**: $NOW_STR  
> **Git Branch**: \`$BRANCH\`  
> **Next Session Prompt**: *"Đọc docs/scratchpad.md và tiếp tục thực thi các bước tiếp theo."*

---

## 🎯 1. Nhiệm vụ Đã Hoàn Thành (Completed in this session)
$([ -n "$COMPLETED" ] && echo "$COMPLETED" || echo "- Đã đồng bộ tiến độ và cập nhật các tệp liên quan.")

---

## 📌 2. Các Bước Kế Tiếp (Next Steps)
$([ -n "$NEXT_STEPS" ] && echo "$NEXT_STEPS" || echo "- Tiếp tục giải quyết các mục tiêu trong kế hoạch hiện tại.")

---

## 🚧 3. Trở Ngại / Rủi Ro Cần Lưu Ý (Blockers & Invariants)
- $BLOCKERS

---

## 📊 4. Trạng Thái Môi Trường Thực Tế (Empirical Runtime State)

### Tệp Tin Vừa Chỉnh Sửa (Git Status):
\`\`\`text
$GIT_STATUS
\`\`\`
EOF

echo -e "\n========================================================"
echo "   SESSION CHECKPOINT RECORDED SUCCESSFULLY!           "
echo "========================================================"
echo "File updated: docs/scratchpad.md"
echo "Bạn có thể an tâm Clear Context / Mở phiên chat mới."
echo -e "Trong phiên mới, chỉ cần nhắc Agent:\n  -> 'Đọc docs/scratchpad.md và tiếp tục công việc'\n"
