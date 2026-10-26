# ECC Harness Task Execution Gate & Squad Scaling Matrix

This rule enforces a strict, disciplined engineering process for all coding and maintenance tasks.

## 1. Autonomous Squad Scaling Matrix (Tự động kích hoạt phòng ban theo độ lớn task)
Agent tự động phân tích độ lớn, phạm vi (blast radius) và mức độ rủi ro của Prompt để kích hoạt cấu hình phòng ban tương ứng:

| Cấp độ Task | Dấu hiệu nhận diện | Phòng ban kích hoạt | Cơ chế kiểm tra chéo |
|---|---|---|---|
| **Tier 1: Atomic / Bounded** | Fix typo, chỉnh CSS/UI nhỏ, sửa 1 hàm đơn giản, 1 file duy nhất | **Solo Dev (`@dev`)** | Dev tự viết test TDD (RED -> GREEN), verify proof, bàn giao ngay để tiết kiệm token. |
| **Tier 2: Feature / Service** | Thêm API endpoint, sửa logic nghiệp vụ, thay đổi 2–4 files trong cùng module | **Trio Squad (`@lead` + `@dev` + `@qa`)** | `@lead` duyệt spec -> `@dev` code TDD -> `@qa` kiểm tra edge-cases và regression. |
| **Tier 3: Epic / High-Risk** | Prompt dài, kiến trúc đa service, Auth/OAuth, Thanh toán, Migration DB, hoặc >4 files | **Full IT Department (`@lead` + `@dev` + `@qa` + `@security` + `@devops`)** | Bắt buộc chạy đầy đủ 5 vai trò, kiểm tra chéo đa chiều, ký biên bản nghiệm thu 5 bên. |

> ⚠️ **Quy tắc đè mức rủi ro (Risk Override)**: Bất kỳ task nào chạm vào **Xác thực (Auth), Thanh toán (Payment), Phân quyền, hoặc Migration Database** đều TỰ ĐỘNG nâng lên **Tier 3** dù prompt ngắn hay dài.

---

## 2. Mandatory Task Lifecycle Gates
```
[Intent / Prompt Input]
      ↓
[Gate 0: Squad Scaling] ────────(Tự động chọn Tier 1, Tier 2 hoặc Tier 3)
      ↓
[Gate 1: Spec & Invariant Analysis] ──(Stop nếu yêu cầu còn mơ hồ)
      ↓
[Gate 2: Implementation Plan] ───────(docs/plans/active/<name>.md nếu Tier 2/3)
      ↓
[Gate 3: Automated Test / TDD] ──────(Bắt buộc test FAIL trước khi viết code)
      ↓
[Gate 4: Clean Implementation] ──────(Code tối giản, strictly typed)
      ↓
[Gate 5: QA & Security Cross-Check] ─(QA test edge-case + Sec quét OWASP/secrets)
      ↓
[Gate 6: Executable Proof & Release] (Exit code 0, semantic Git commit)
      ↓
[Claim Completion]
```

## 3. Non-Negotiable Directives:
1. **Never edit without authority or clear intent**: If requirements are ambiguous, clarify before changing code.
2. **Never break existing contracts**: Maintain API schema stability and backward compatibility.
3. **Never claim completion without fresh executable evidence**: Static typecheck + test pass + runtime verification output must be present.
