# Universal AI Agent Harness & Skills Framework Starter

> Universal Turnkey Framework chuẩn hóa đa nền tảng cho mọi AI Coding Assistant.
> Tương thích nguyên bản (100% Native) với Antigravity IDE, Claude CLI (Claude Code), OpenAI Codex, OpenCode, Cursor, Windsurf và GitHub Copilot.

---

## 1. Universal Compatibility Matrix

Mỗi công cụ AI Coding Assistant sử dụng một entrypoint cấu hình và định dạng context riêng. Bộ khung này chuẩn hóa toàn bộ các công cụ về một hệ thống kỷ luật kỹ thuật và bất biến kiến trúc (Invariants & Guardrails) duy nhất:

| Công cụ AI | File Entrypoint | Cơ chế hoạt động |
|---|---|---|
| **Antigravity IDE** | `AGENTS.md` & `.agents/hooks.json` | Tự động kích hoạt lifecycle hooks, department scaling và subagents |
| **Claude CLI (Claude Code)** | `CLAUDE.md` | Đọc trực tiếp project rules, slash commands (`/plan`, `/tdd`, `/review`) |
| **OpenCode Harness** | `OPENCODE.md` & `AGENTS.md` | Nạp quy chuẩn Harness và task shapes |
| **OpenAI Codex / ChatGPT CLI** | `CODEX.md` & `AGENTS.md` | Thực thi theo ranh giới kiểm soát và TDD |
| **Cursor IDE** | `.cursorrules` | Ép các rule TDD và task execution gates vào prompt context |
| **Windsurf IDE** | `.windsurfrules` | Quy định guardrails và headless browser automation |
| **GitHub Copilot** | `.github/copilot-instructions.md` | Hướng dẫn ngữ cảnh cho Copilot Chat & Copilot Workspace |

---

## 2. Core Engineering Discipline

Mọi agent khi thực thi trong repository đều bị ràng buộc bởi hệ thống kỷ luật kỹ thuật cao nhất, không ngoại lệ:

### A. 10 Invariants của Kỹ Sư Trưởng (`docs/INVARIANTS.md`)
1. **Never Fabricate (Zero Hallucination)**: Tuyệt đối không phỏng đoán, không bịa đặt log thực thi hay API không tồn tại.
2. **Never Flatter (Zero Sycophancy)**: Trung thực kỹ thuật, dũng cảm phản biện kiến trúc rủi ro hoặc yêu cầu kém an toàn.
3. **Always Find Root Cause**: Cô lập nguyên nhân gốc rễ bằng binary search/systematic debugging, không vá ngọn tạm bợ.
4. **Always State Risks (Adversarial Thinking)**: Luôn chỉ ra đánh đổi và rủi ro; không bao giờ gọi kiến trúc là "hoàn hảo".
5. **Always Calibrate Confidence**: Chỉ tin vào số liệu thực thi (`Runtime > Tests > Code > Docs`).
6. **Learn From Every Outcome**: Tự động đúc kết bài học và cập nhật failure journal sau mỗi sự cố.
7. **Respect Constraints**: Giải quyết bài toán trong điều kiện thực tế (Hardware, Network, Deadline, Legacy Code).
8. **Disagree With Evidence**: Phản biện bằng metrics, RFC spec, log và benchmark; không cãi bằng cảm tính.
9. **Know Your Expertise Limits**: Nhận thức rõ ranh giới hiểu biết và công khai với người dùng khi cần ủy quyền.
10. **User Decides Last**: Agent là Kỹ sư trưởng cố vấn và thực thi, Người dùng nắm quyền quyết định tối cao.

### B. 5 Guardrail Mandates
1. **Empirical Metrics Only**: Mọi nhận định, chẩn đoán và báo cáo hoàn thành đều phải dẫn chứng số liệu thực thi đo lường được (exit code 0, test pass count, RAM/CPU metrics, HTTP status code). Cấm đoán mò hoặc dùng log giả lập.
2. **Strict TDD (Red-Green-Refactor)**: Bắt buộc viết bài kiểm thử tự động chứng minh FAIL (RED) trước khi viết code logic (GREEN), sau đó mới REFACTOR.
3. **Autonomous Subagents & Cross-Checking**: Tách context và spawn subagent độc lập (`.agents/roles/`) để kiểm tra chéo kiến trúc, hợp đồng API và tính tương thích giữa các microservices/modules.
4. **Continuous Convergence Loop & Zero-Drop**: Khi prompt chứa nhiều lỗi (như lỗi A và B) hoặc có cờ `/goal`, Agent bắt buộc phân rã Ma trận mục tiêu (`zero-drop-multi-goal.md`), dập tắt lần lượt từng lỗi kèm test biên/negative, và duy trì vòng lặp `Test RED -> Fix -> Test GREEN -> Full Build & Verify` cho đến khi 100% mục tiêu đạt Exit Code 0. Nghiêm cấm dừng sớm hay báo cáo dở dang khi chưa có Bảng bằng chứng thực thi.
5. **Auto-Experience Journaling**: Sau khi dập xong bug/defect hoặc hoàn thành một milestone/tính năng mới, Agent BẮT BUỘC tự động ghi nhận nguyên nhân gốc rễ và bài học bất biến vào `docs/memory/failure-journal.md` (qua `scripts/record-lesson.ps1` hoặc `.sh`) trước khi nghiệm thu.

### C. 3-Strike Circuit Breaker & Anti-Loop
Khi gặp lỗi giống hệt nhau 3 lần liên tiếp, Agent BẮT BUỘC DỪNG LẠI NGAY LẬP TỨC (`anti-loop-circuit-breaker.md`). Tuyệt đối không loop terminal hoặc sửa code mù quáng. Xuất báo cáo chẩn đoán `[CIRCUIT BREAKER TRIGGERED]` kèm 2-3 hướng xử lý khả thi để người dùng quyết định.

### D. Anti-AI Slop & Human Engineering Voice
Loại bỏ hoàn toàn hơn 25 từ ngữ sáo rỗng AI (*delve, tapestry, crucial, testament, pivotal, beacon, unleash, paramount...*), triệt tiêu gạch ngang em-dash thừa, không hỏi tự trả lời (hypophora). Giao tiếp gãy gọn, sắc bén, trực diện như Kỹ sư trưởng (`human-identity-anti-slop.md`).

### E. Anti-AI Slop UI & Zero-Emoji Policy
Nghiêm cấm tuyệt đối dùng Emoji làm icon trong giao diện ứng dụng (button, badge, card, nav). Bắt buộc dùng SVG Icon chuẩn công nghiệp (`lucide-react`, `@heroicons/react`). Cấm nền gradient tím rập khuôn (`from-purple-500 to-indigo-600`), chuẩn hóa sang Design Tokens trung tính (Neutral Zinc/Slate `#09090b`, viền `border-white/10`, phân cấp text `text-zinc-100` / `text-zinc-400`). Chi tiết: `.agents/rules/anti-ai-slop-ui.md`.

### F. Autonomous Web & GitHub Research Protocol
Khi gặp thư viện mới, package mới cập nhật hoặc repo GitHub lạ: CẤM BỊA ĐẶT API. Bắt buộc tra cứu trước qua GitHub CLI (`gh repo view`, `gh search code`), Web Search hoặc script `scripts/inspect-package.ps1` để lấy chữ ký hàm thật từ chính tác giả trước khi viết code. Chi tiết: `.agents/rules/autonomous-research.md`.

---

## 3. Polyglot Architecture & Skills Armory

### A. Hệ sinh thái 68 Subagent Roles (`.agents/roles/`)
Bộ 68 vai trò chuyên trách: `architect`, `code-reviewer`, `database-reviewer`, `performance-optimizer`, `security-reviewer`, `tdd-guide`, `spec-miner`, `network-architect`, `react-build-resolver`, `go-build-resolver`, `rust-build-resolver`, `django-build-resolver`...

### B. 35 Bộ Quy Trình Tự Động (`.agents/workflows/`)
Fullstack Web Suite, Enterprise API Suite, Cybersecurity Defense Suite, Data Engineering Suite, DevOps Cloud Suite, Adversarial Validation, Epistemic Check, Reflection Loop...

### C. Danh mục 87+ Máy Chủ MCP Đã Kiểm Định (`.agents/mcp_catalog.json`)
Cấu hình 1-click cho PostgreSQL, Supabase, Docker, Kubernetes, DuckDB, Trivy Scanner, REA (Reverse Engineer Anything), Codebase Memory, Tavily Search, ArXiv, PubMed...

### D. Global Armory Bridge & skills.sh
- **Local Core Skills**: 103 skills thực chiến tích hợp sẵn trong `.agents/skills/` (Superpowers, REA Reverse Engineer Anything, Microservices, Cloud DevOps).
- **Global Package Hub**: Tích hợp cổng `find-skills` kết nối trực tiếp với package manager mã nguồn mở [skills.sh](https://skills.sh/) (`npx skills find` / `npx skills add`) cùng kho 2.000+ skills chuyên sâu tại `~/.gemini/rules/skills/`.

---

## 4. Installation & Profile Selection

Bộ cài đặt hỗ trợ Zero-Touch Auto Discovery hoặc cài đặt theo Profile chuyên biệt để tối ưu dung lượng repository:

| Profile | Mục đích sử dụng | Nội dung tích hợp |
|---|---|---|
| `auto` *(Mặc định)* | Tự động quét cấu trúc repo đích | Tự động chọn `web-fullstack`, `security-re` hoặc `all` dựa trên file phát hiện |
| `minimal` | Dự án nhỏ, script đơn lẻ | Core Invariants, Strict TDD, Systematic Debugging, Plan & Review |
| `web-fullstack` | Web, REST/GraphQL API, Microservices | Core + React/Next.js, Python, Go, Rust, Database Migrations, Docker CI/CD |
| `security-re` | Dịch ngược và An toàn thông tin | Core + REA, IDA, Ghidra, Radare2, Frida, Pentest Tools, Exploit, Forensics |
| `all` | Toàn bộ kho công cụ | Trọn bộ 103 skills, 68 roles, 35 workflows và 87 MCP servers |

### Trên Windows (PowerShell):
```powershell
git clone https://github.com/tdnhat1809/agent_harness.git
cd agent_harness

# Cài đặt tự động nhận diện stack:
.\install.ps1 -Target "D:\path\to\your-project"

# Hoặc chỉ định profile cụ thể:
.\install.ps1 -Target "D:\path\to\your-project" -Profile web-fullstack
```

### Trên Linux / macOS (Bash):
```bash
git clone https://github.com/tdnhat1809/agent_harness.git
cd agent_harness
chmod +x install.sh

# Cài đặt tự động nhận diện stack:
./install.sh /path/to/your-project

# Hoặc chỉ định profile cụ thể:
./install.sh /path/to/your-project security-re
```

> [!NOTE]
> **Cơ chế Smart Merge bảo vệ file cấu hình hiện có**:
> Nếu repo đích đã tồn tại các file `AGENTS.md`, `CLAUDE.md`, hoặc `CODEX.md`, script chỉ ghép khối `<!-- HARNESS:BEGIN --> ... <!-- HARNESS:END -->` vào cuối file, bảo đảm không ghi đè hay làm mất cấu hình riêng của dự án.

---

## 5. Mechanical Git Hooks

Khi cài đặt vào repository có Git, framework tự động thiết lập các rào chắn cơ học ngăn chặn sai sót:

- **`pre-commit` Hook**:
  - **Secret Shield**: Quét phát hiện và chặn đứng commit nếu chứa file nhạy cảm (`.env`, `.pem`, `.key`, `id_rsa`) hoặc API keys (`ghp_`, `sk-`, `AKIA...`).
  - **Strict TDD Check**: Cảnh báo ngay nếu có code logic bị sửa đổi mà không có test tương ứng đi kèm.
  - **Anti-Blob Shield**: Chặn các tệp binary rác (`.exe`, `.dll`, `.tar`, `.zip`, `.pyc`).
- **`commit-msg` Hook (Defect Journal Enforcer)**:
  - **Failure Journal Gate**: Tự động chặn bất kỳ commit sửa lỗi nào (`fix:`, `hotfix:`, `bug:`) nếu Agent chưa ghi nhận nguyên nhân gốc rễ và bài học vào `docs/memory/failure-journal.md`. Bắt buộc chạy `record-lesson.ps1` mới được phép commit.
- **`pre-push` Hook**:
  - Kiểm tra trạng thái các kế hoạch dài hạn còn tồn đọng trong `docs/plans/active/` trước khi đẩy code lên remote.

---

## 6. Advanced Operational Tooling

Bộ harness tích hợp sẵn bộ CLI công cụ tiêu chuẩn giúp tăng tốc độ làm việc và bảo đảm kỷ luật kỹ thuật:

| Công cụ | Lệnh thực thi (PowerShell / Bash) | Chức năng chính |
|---|---|---|
| **Dynamic Context Sharding** | `.\scripts\route-context.ps1` / `./scripts/route-context.sh` | Phân loại intent, chọn lọc rules và skills theo domain, loại bỏ 70-90% token rác chống loãng chú ý |
| **Visual UI & Anti-AI Slop Auditor** | `.\scripts\ui-audit.ps1` / `./scripts/ui-audit.sh` | Kiểm định UI component bắt lỗi icon emoji, gradient tím và kiểm tra khả năng tiếp cận WCAG (a11y) |
| **Ephemeral Sandbox Runner** | `.\scripts\sandbox-run.ps1` / `./scripts/sandbox-run.sh` | Chạy lệnh trong container Docker cô lập hoặc ephemeral snapshot chống tác động máy host |
| **Agent Red-Team Benchmark** | `.\scripts\test-agent-adherence.ps1` / `./scripts/test-agent-adherence.sh` | Bộ 6 thử thách sát hạch bẫy hành vi: chống rớt mục tiêu, chống leak secret, chống slop UI, ép failure journal |
| **Semantic Memory Indexer** | `.\scripts\query-memory.ps1` / `./scripts/query-memory.sh` | Tra cứu kinh nghiệm và quyết định kiến trúc với thuật toán xếp hạng BM25 và từ điển đồng nghĩa kỹ thuật |
| **Polyglot Test Runner** | `.\scripts\verify.ps1` / `./scripts/verify.sh` | Tự nhận diện test engine (Node, Python, Go, Rust, Java...), đo thời gian thực thi và exit code |
| **Mutation Testing Guard** | `.\scripts\mutation-test.ps1` / `./scripts/mutation-test.sh` | Tự động tiêm lỗi đột biến vào code logic để thẩm định chất lượng test (Chống test ảo/hollow test) |
| **Workspace Self-Heal** | `.\scripts\self-heal.ps1` / `./scripts/self-heal.sh` | Tạo snapshot trước task, dọn cache rác, rollback an toàn về trạng thái sạch nhưng bảo toàn `docs/memory/` |
| **Plan Scaffolder & Kanban** | `.\scripts\new-plan.ps1`, `.\scripts\plan-status.ps1` | Khởi tạo plan chuẩn, theo dõi tiến độ Kanban % ngay trên terminal, tự động lưu trữ khi hoàn tất |
| **Automated PR Generator** | `.\scripts\generate-pr.ps1` / `./scripts/generate-pr.sh` | Phân tích git diff, trích xuất bảng bằng chứng verify và bài học kinh nghiệm để sinh PR description chuẩn |
| **Package Inspector** | `.\scripts\inspect-package.ps1` / `./scripts/inspect-package.sh` | Tra cứu package registry (npm, PyPI, crates.io, Go, GitHub) lấy chữ ký hàm thật, chống ảo giác API |
| **Failure Journal Recorder** | `.\scripts\record-lesson.ps1` / `./scripts/record-lesson.sh` | Ghi nhận sự cố và bài học bất biến vào `docs/memory/failure-journal.md` |
| **Architecture Decision Record** | `.\scripts\new-adr.ps1 -Title "..."` / `./scripts/new-adr.sh` | Tự động sinh file ADR tiếp theo trong `docs/decisions/` theo cấu trúc chuẩn |
| **Context Checkpoint** | `.\scripts\checkpoint.ps1` / `./scripts/checkpoint.sh` | Đóng gói snapshot tiến độ vào `docs/scratchpad.md` để an tâm Clear Context / mở phiên chat mới |
| **Self-Regression Benchmark** | `.\scripts\eval-harness.ps1` / `./scripts/eval-harness.sh` | Chạy 4 bài test sát hạch tự động (Secret Shield, TDD Guard, Lint, Verify) và chấm điểm chất lượng (100/100 Grade A+) |
| **Harness Linter** | `.\scripts\lint-harness.ps1 -Strict` | Kiểm tra tính toàn vẹn của 103 skills, 87 MCP servers và hooks |
| **System Doctor** | `.\scripts\doctor.ps1` / `./scripts/doctor.sh` | Chẩn đoán toàn diện môi trường runtime, Git Hooks và các file entrypoints |

---

## 7. Persistent Memory Architecture

Agent duy trì tính nhất quán xuyên suốt giữa các phiên làm việc độc lập qua 2 tài liệu trung tâm:

1. [docs/memory/failure-journal.md](file:///D:/python/agent-harness-template/docs/memory/failure-journal.md): Danh mục các sự cố kỹ thuật, nguyên nhân gốc rễ và bài học rút ra để Agent không lặp lại lỗi cũ.
2. [docs/memory/architectural-precedents.md](file:///D:/python/agent-harness-template/docs/memory/architectural-precedents.md): Các quyết định kiến trúc, quy chuẩn mã nguồn và cổng mạng đã phê duyệt để Agent không hỏi lại các quyết định đã chốt.

---

## 8. Agent Workflows

1. **Task nhỏ (Bounded Change)**: Fix bug, thêm hàm, đổi CSS: Agent thực thi theo TDD (test RED -> code GREEN -> chứng minh proof), phản hồi gãy gọn.
2. **Task lớn (Durable Planned Change)**: Thêm tính năng mới, tái cấu trúc hệ thống: Agent phát hiện "Work Shape" qua `docs/WORKFLOW.md`, sinh plan trong `docs/plans/active/<ten-task>.md`, thực hiện theo từng checkpoint và lưu bằng chứng vào `docs/plans/completed/`.
3. **Chống ảo giác (Zero-Hallucination)**: Hook `pre_complete` và rule `guardrails.md` ngăn chặn agent tuyên bố hoàn thành nếu chưa có kết quả thực thi lệnh thực tế trong terminal.

---

## 9. License

MIT License. Tự do sử dụng, chỉnh sửa và tích hợp vào mọi dự án cá nhân cũng như thương mại.
