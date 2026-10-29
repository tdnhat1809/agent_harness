# Zero-Drop Checklist & Multi-Goal Convergence Protocol

Quy tắc bất khả xâm phạm chống hiện tượng **bỏ sót lỗi trong prompt đa mục tiêu (Sub-Goal Neglect)** và **kiểm thử hời hợt vội vã báo cáo (Premature Completion / Happy-Path Bias)**.

---

## 1. Nguyên tắc Không Bỏ Sót (Zero-Drop Mandate)

Khi nhận prompt chứa từ **2 lỗi hoặc 2 yêu cầu trở lên** (ví dụ: Lỗi A và Lỗi B), hoặc khi có cờ **/goal**:

### ⛔ Điều cấm kỵ tuyệt đối:
- **CẤM NHẢY VÀO CODE NGAY**: Không được bắt tay vào sửa mã nguồn trước khi trích xuất danh sách mục tiêu.
- **CẤM SỬA NỬA VỜI**: Tuyệt đối không sửa xong lỗi A rồi vội vã báo cáo mà bỏ quên lỗi B.
- **CẤM BÁO CÁO BẰNG VĂN XUÔI**: Cấm dùng các câu sáo rỗng ("em đã kiểm tra kỹ rồi", "hoạt động hoàn hảo") mà không có log terminal thật.

### ✅ Hành động bắt buộc ở Turn 1:
Agent bắt buộc phải phân rã yêu cầu thành **Ma trận Mục tiêu (Goal Checklist Matrix)** ở đầu câu trả lời:

```markdown
### 🎯 Multi-Goal Decomposition Matrix
- [ ] Target 1: <Lỗi A> -> Test RED chứng minh -> Code GREEN -> Verify
- [ ] Target 2: <Lỗi B> -> Test RED chứng minh -> Code GREEN -> Verify
- [ ] Target 3: Full-Suite Project Regression (`scripts/verify.ps1`) -> Exit code 0
```

---

## 2. Rào Chắn 3 Tầng Kiểm Thử Bắt Buộc (3-Tier Verification Gate)

Một lỗi hoặc tính năng **CHỈ ĐƯỢC COI LÀ HOÀN TẤT** khi vượt qua trọn vẹn 3 tầng kiểm thử đo lường được:

1. **Tầng 1: Negative & Boundary Proof (Kiểm thử Nghịch & Biên)**:
   - Bắt buộc phải có bài test cho các kịch bản bất lợi: input `null`, chuỗi rỗng `""`, giá trị âm, ID không tồn tại, ngoại lệ (Exception), hoặc timeout.
   - Cấm chỉ test mỗi trường hợp dữ liệu hoàn hảo (Happy-path testing).
2. **Tầng 2: Unit & Integration Green Proof**:
   - Bài test cho logic chính phải chạy và đạt Exit Code 0 trên terminal thật.
3. **Tầng 3: Full-Suite Regression & Full Build**:
   - Bắt buộc gọi lệnh [`scripts/verify.ps1`](file:///scripts/verify.ps1) (hoặc `./scripts/verify.sh`) chạy toàn bộ test suite của dự án để chứng minh việc sửa lỗi không gây tác dụng phụ (side-effects) làm gãy các module khác.
   - Chạy build toàn dự án (`npm run build`, `cargo check`, `go build ./...`, `tsc --noEmit`).

---

## 3. Cưỡng chế Triệu tập Subagent Tự động (Autonomous Subagent Mandate)

Để triệt tiêu điểm mù chủ quan của người viết code (Author Blindspot):

- **Điều kiện kích hoạt**:
  * Khi prompt chứa $\ge 2$ lỗi hoặc tính năng độc lập.
  * Hoặc khi task có gắn cờ **/goal** (overnight / long-running).
  * Hoặc khi phạm vi sửa đổi chạm vào $\ge 3$ files.
- **Quy trình phân công**:
  * Agent chính BẮT BUỘC triệu tập **Subagent `@qa` (Tester / Adversarial Reviewer)** hoặc phân rã task song song qua skill `dispatching-parallel-agents` / `subagent-driven-development`.
  * Subagent `@qa` chịu trách nhiệm độc lập:
    1. Kiểm tra chéo xem Lỗi B đã được sửa và có test chưa.
    2. Ném các ca biên độc hại (adversarial inputs) để cố gắng phá vỡ code của `@dev`.
    3. Chỉ khi `@qa` ký biên bản nghiệm thu (Sign-off) thì Agent chính mới được phép bàn giao cho người dùng.

---

## 4. Vòng lặp Hội tụ Khép kín (Continuous Convergence Loop)

Quy trình bắt buộc lặp lại tuần tự theo sơ đồ khép kín:

```
[Prompt đa mục tiêu: A, B]
       ↓
[Tạo Goal Checklist Matrix]
       ↓
┌───> [Viết test RED cho A và B] ──(Cả A và B đều phải chứng minh FAIL trước)
│      ↓
│     [Sửa code cho A] ─────────────(Test A chuyển sang GREEN)
│      ↓
│     [Sửa code cho B] ─────────────(Test B chuyển sang GREEN)
│      ↓
│     [Chạy verify.ps1 toàn dự án] ─(Full test suite & Build)
│      ↓
└─── [Còn lỗi hoặc gãy test cũ?] ───(Có: Quay lại vòng lặp | Không: Đi tiếp)
       ↓
[Xuất Bảng Bằng chứng Thực thi] ────(Proof-of-Execution Matrix)
       ↓
[Claim Completion / <!-- GOAL_COMPLETE -->]
```

---

## 5. Bảng Bằng chứng Nghiệm thu Bắt buộc (Mandatory Proof Table)

Trước khi tuyên bố hoàn tất hoặc đưa cờ `<!-- GOAL_COMPLETE -->`, phản hồi cuối cùng của Agent **BẮT BUỘC PHẢI CHỨA BẢNG SAU**:

```markdown
### 📊 Proof-of-Execution Matrix

| Mục tiêu | Lệnh kiểm thử thực tế | Exit Code | Kết quả đo lường | Trạng thái |
|---|---|:---:|---|:---:|
| **Target 1: Lỗi A** | `<cmd unit test A>` | `0` | X passed, 0 failed | ✅ Verified |
| **Target 2: Lỗi B** | `<cmd unit test B>` | `0` | Y passed, 0 failed | ✅ Verified |
| **Tầng biên (Negative)** | `<cmd edge-case test>` | `0` | Z passed, 0 failed | ✅ Verified |
| **Toàn bộ hệ thống** | `powershell -File .\scripts\verify.ps1` | `0` | All suites green in N.Ns | ✅ Zero Regression |
```

> ⛔ **VI PHẠM NGHIÊM TRỌNG**: Mọi báo cáo kết thúc task mà không có bảng số liệu thực tế kèm Exit Code 0 đều bị coi là **Báo cáo khống (Vi phạm Invariant 1: Never Fabricate & Invariant 5: Always Calibrate Confidence)**.
