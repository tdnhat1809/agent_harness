# 🛡️ Universal AI Agent Harness & Skills Framework Starter

> **Bộ khung tối thượng chuẩn hóa đa nền tảng (Universal Turnkey Framework) cho mọi AI Coding Assistant.**  
> Tương thích nguyên bản (100% Native) với: **Antigravity IDE, Claude CLI (Claude Code), OpenAI Codex, OpenCode, Cursor, Windsurf, và GitHub Copilot**.

---

## 🚀 1. Khả năng tương thích vạn năng (Universal Harness Compatibility)

Mỗi công cụ AI Coding Assistant lại tìm kiếm một file cấu hình hoặc context entrypoint khác nhau. Bộ khung này tích hợp sẵn các cổng kết nối chuẩn tới **Hệ thống bất biến (Invariants & Guardrails)** duy nhất:

| Công cụ AI | File Entrypoint kích hoạt | Cơ chế hoạt động |
|---|---|---|
| **Claude CLI (Claude Code)** | `CLAUDE.md` | Đọc trực tiếp project rules, slash commands (`/plan`, `/tdd`, `/review`) |
| **OpenCode Harness** | `OPENCODE.md` & `AGENTS.md` | Nạp quy chuẩn Harness và task shapes |
| **OpenAI Codex / ChatGPT CLI** | `CODEX.md` & `AGENTS.md` | Thực thi theo ranh giới kiểm soát và TDD |
| **Antigravity IDE** | `AGENTS.md` & `.agents/hooks.json` | Tự động kích hoạt lifecycle hooks và subagents |
| **Cursor IDE** | `.cursorrules` | Ép các rule TDD và task execution gates vào prompt context |
| **Windsurf IDE** | `.windsurfrules` | Quy định guardrails và headless automation |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Hướng dẫn ngữ cảnh cho Copilot Chat & Agent |

---

## 🌟 2. Bộ Kỷ luật kỹ thuật cốt lõi (Guardrails & Invariants Mandate)

Mọi agent khi chạy trong repo này đều bị ràng buộc bởi hệ thống kỷ luật kỹ thuật cao nhất:

### A. 10 Điều Răn Bất Biến (Chief Engineer's Invariants - `docs/INVARIANTS.md`)
1. **Never Fabricate (Zero Hallucination)**: Không phỏng đoán, không bịa đặt log hay API không tồn tại.
2. **Never Flatter (Zero Sycophancy)**: Trung thực kỹ thuật, dũng cảm phản biện kiến trúc rủi ro.
3. **Always Find Root Cause**: Cô lập nguyên nhân gốc rễ bằng binary search, không vá ngọn tạm bợ.
4. **Always State Risks (Adversarial Thinking)**: Luôn nêu rõ đánh đổi và rủi ro; không bao giờ gọi giải pháp là "hoàn hảo".
5. **Always Calibrate Confidence**: Chỉ tin vào số liệu thực tế (`Runtime > Tests > Code > Docs`).
6. **Learn From Every Outcome**: Rút ra bài học và cập nhật invariant sau mỗi sự cố.
7. **Respect Constraints**: Giải quyết bài toán trong điều kiện thực tế (Hardware, Network, Deadline).
8. **Disagree With Evidence**: Phản biện bằng metrics, RFC spec và benchmark, không cãi bằng cảm tính.
9. **Know Your Expertise Limits**: Nhận thức rõ ranh giới hiểu biết và công khai với người dùng.
10. **User Decides Last**: Agent là Kỹ sư trưởng cố vấn và thực thi, Người dùng nắm quyền quyết định cuối cùng.

### B. 4 Guardrails Mandates (Strict Engineering Discipline)
1. 📊 **Nói chuyện bằng số liệu thực tế (Empirical Metrics Only)**: Mọi chẩn đoán hay kết luận phải dựa trên exit code, logs thực tế, test outputs, RAM/CPU metrics.
2. 🔴🟢 **Strict TDD (Red-Green-Refactor)**: Bắt buộc viết bài test tự động và chạy để chứng minh nó **FAIL (RED)** trước khi viết bất kỳ dòng code logic chính nào.
3. 🤖 **Tự động spawn subagent đối chiếu ngữ cảnh (Subagent Cross-Check)**: Tách biệt context, kiểm tra độc lập tính tương thích giữa các microservices/modules.
4. 🔄 **Vòng lặp liên tục tới khi đạt Goal (Continuous Convergence Loop)**: `Chẩn đoán ➔ Test RED ➔ Implement GREEN ➔ Verify Proof ➔ Đo lường số liệu` đến khi đạt 100% mục tiêu.

### C. ⚡ 3-Strike Circuit Breaker & Anti-Loop
Khi gặp lỗi giống hệt nhau 3 lần liên tiếp, Agent tự động ngắt vòng lặp ngay lập tức (`anti-loop-circuit-breaker.md`), xuất chẩn đoán và đề xuất 2-3 hướng xử lý cho người dùng thay vì hao phí token vô tận.

### D. 👤 Anti-AI Slop & Natural Senior Engineering Voice
Loại bỏ hoàn toàn hơn 25 từ ngữ sáo rỗng AI (*delve, tapestry, crucial, testament, pivotal, beacon, unleash, paramount...*), triệt tiêu em-dash thừa thãi, giao tiếp sắc bén, trực diện theo chuẩn Kỹ sư trưởng (`human-identity-anti-slop.md`).

---

## 📂 3. Hỗ trợ mọi loại dự án (Polyglot, Subagents & Mega-Skills Armory)

### A. Hệ sinh thái 68 Subagent Roles (`.agents/roles/`)
Bộ 68 vai trò chuyên trách: `architect`, `code-reviewer`, `database-reviewer`, `performance-optimizer`, `security-reviewer`, `tdd-guide`, `spec-miner`, `network-architect`, `react-build-resolver`, `go-build-resolver`, `rust-build-resolver`, `django-build-resolver`...

### B. 35 Bộ Quy Trình Tự Động (`.agents/workflows/`)
Fullstack Web Suite, Enterprise API Suite, Cybersecurity Defense Suite, Data Engineering Suite, DevOps Cloud Suite, Adversarial Validation, Epistemic Check, Reflection Loop...

### C. Danh mục 87+ Máy Chủ MCP Đã Kiểm Định (`.agents/mcp_catalog.json`)
Cấu hình 1-click cho PostgreSQL, Supabase, Docker, Kubernetes, DuckDB, Trivy Scanner, REA (Reverse Engineer Anything), Codebase Memory, Tavily Search, ArXiv, PubMed...

### D. Cầu nối Kho Vũ Khí Toàn Cầu (Global Armory Bridge)
Tích hợp sẵn 97 skills cốt lõi trong `.agents/skills/` (gồm trọn bộ kỹ năng REA Reverse Engineer Anything, Microservices, Cloud DevOps) và tự động kết nối theo nhu cầu tới kho **2.000+ skills chuyên sâu** tại `~/.gemini/rules/skills/` (Active Directory attacks, Volatility memory analysis, KiCad EDA PCB layout, Manim animation, ZTNA...).

---

## 🚀 4. Hướng dẫn cài đặt theo Profile (Modular 1-Click Installer)

Bộ cài đặt hỗ trợ **Tự động nhận diện (Zero-Touch Auto Discovery)** hoặc chọn Profile chuyên biệt để tránh làm phình to repo đích:

| Profile | Mục đích | Các Skills tích hợp tiêu biểu |
|---|---|---|
| `auto` *(Mặc định)* | Tự động quét file repo đích | Tự động chọn `web-fullstack`, `security-re` hoặc `all` dựa trên file phát hiện |
| `minimal` | Dự án nhỏ / script nhẹ | Core Invariants, Strict TDD, Systematic Debugging, Plan & Review |
| `web-fullstack` | Web / API / Microservices | Core + React/Next.js, Python, Go, Rust, Database Migrations, Docker CI/CD |
| `security-re` | Dịch ngược & An toàn thông tin | Core + REA, IDA, Ghidra, Radare2, Frida, Pentest Tools, Exploit, Forensics |
| `all` | Đầy đủ toàn bộ kho vũ khí | Toàn bộ 97 skills + 68 roles + 35 workflows |

### Trên Windows (PowerShell):
```powershell
git clone https://github.com/tdnhat1809/agent_harness.git
cd agent_harness

# Cài đặt tự nhận diện stack (khuyên dùng):
.\install.ps1 -Target "D:\path\to\your-new-project"

# Hoặc chỉ định profile cụ thể:
.\install.ps1 -Target "D:\path\to\your-new-project" -Profile web-fullstack
```

### Trên Linux / macOS (Bash):
```bash
git clone https://github.com/tdnhat1809/agent_harness.git
cd agent_harness
chmod +x install.sh

# Cài đặt tự nhận diện stack:
./install.sh /path/to/your-new-project

# Hoặc chỉ định profile cụ thể:
./install.sh /path/to/your-new-project security-re
```

> 🛡️ **Tính năng bảo vệ file cũ (Smart Merge)**:  
> Script tự động kiểm tra: Nếu repo đích đã có `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, script **chỉ ghép khối `<!-- HARNESS:BEGIN -->`** vào cuối file. Không bao giờ ghi đè làm mất hướng dẫn cấu hình riêng của dự án đó!

---

## 🛡️ 5. Hệ thống Ràng buộc Cơ học (Mechanical Git Hooks)

Khi cài đặt vào repo đích có Git, framework tự động thiết lập:
- **`pre-commit` Hook**:
  - 🛑 **Secret Shield**: Quét phát hiện và chặn đứng commit nếu có tệp `.env`, `.pem`, `.key`, `id_rsa` hoặc API keys (`ghp_`, `sk-`, `AKIA...`).
  - 🛑 **Strict TDD Check**: Cảnh báo ngay nếu có code logic bị sửa đổi mà không có test tương ứng đi kèm.
  - 🛑 **Anti-Blob Shield**: Chặn các tệp binary rác (`.exe`, `.dll`, `.tar`, `.zip`, `.pyc`).
- **`pre-push` Hook**: Kiểm tra trạng thái kế hoạch dài hạn (`docs/plans/active/`) trước khi đẩy code lên remote.

---

## 🛠️ 6. Bộ công cụ Vận hành Nâng cao (Advanced Operational Tooling)

Bộ harness tích hợp sẵn bộ CLI công cụ tiêu chuẩn giúp tăng tốc độ làm việc và ép kỷ luật kỹ thuật:

| Công cụ | Lệnh thực thi (PowerShell / Bash) | Tính năng chính |
|---|---|---|
| **Polyglot Test Runner** | `.\scripts\verify.ps1` / `./scripts/verify.sh` | Tự nhận diện test engine (Node, Python, Go, Rust, Java...), đo lường số liệu thời gian và exit code thực tế |
| **Failure Journal** | `.\scripts\record-lesson.ps1` / `./scripts/record-lesson.sh` | Ghi nhanh sự cố và bài học bất biến vào `docs/memory/failure-journal.md` để chống "mất trí nhớ theo phiên" |
| **New ADR Generator** | `.\scripts\new-adr.ps1 -Title "..."` / `./scripts/new-adr.sh` | Tự động sinh file Architecture Decision Record tiếp theo trong `docs/decisions/` theo chuẩn mẫu |
| **Context Checkpoint** | `.\scripts\checkpoint.ps1` / `./scripts/checkpoint.sh` | Đóng gói snapshot tiến độ vào `docs/scratchpad.md` để an tâm Clear Context / mở phiên chat mới |
| **Harness Linter** | `.\scripts\lint-harness.ps1 -Strict` | Kiểm định 100% tính toàn vẹn của 97 skills, 87 MCP servers và hooks |
| **System Doctor** | `.\scripts\doctor.ps1` / `./scripts/doctor.sh` | Chẩn đoán toàn diện môi trường runtime, Git Hooks và các file entrypoints |

---

## 🧠 7. Hệ thống Trí nhớ Dài hạn (Cross-Session Persistent Memory)

Agent không còn bị "mất trí nhớ" giữa các phiên chat nhờ 2 tệp lưu trữ trung tâm:
1. [docs/memory/failure-journal.md](file:///D:/python/agent-harness-template/docs/memory/failure-journal.md): Danh mục các sự cố kỹ thuật, nguyên nhân gốc rễ và bài học rút ra để Agent không bao giờ lặp lại lỗi cũ.
2. [docs/memory/architectural-precedents.md](file:///D:/python/agent-harness-template/docs/memory/architectural-precedents.md): Các quyết định kiến trúc, quy chuẩn mã nguồn và cổng mạng đã được phê duyệt để Agent không hỏi lại các câu hỏi cũ.

---

## 🧭 8. Quy trình làm việc với Agent

1. **Task nhỏ (Bounded Change)**: Fix bug, thêm hàm, đổi CSS ➔ Agent tự làm theo TDD (test RED ➔ code GREEN ➔ chứng minh proof), phản hồi cực nhanh.
2. **Task lớn (Durable Planned Change)**: Thêm tính năng mới, refactor lớn ➔ Agent tự phát hiện "Work Shape" qua `docs/WORKFLOW.md`, tự sinh plan trong `docs/plans/active/<ten-task>.md`, thực hiện theo từng checkpoint và lưu bằng chứng vào `docs/plans/completed/`.
3. **Chống ảo giác (Zero-hallucination)**: Hook `pre_complete` và rule `guardrails.md` ngăn chặn agent nói suông nếu chưa chạy lệnh thực tế trong terminal.

---

## 📄 License
MIT License. Tự do sử dụng, chỉnh sửa và tích hợp vào mọi dự án cá nhân cũng như thương mại.
