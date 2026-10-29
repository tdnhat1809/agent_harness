# Anti-AI-Slop UI & Premium Frontend Craft Rule

Quy tắc bắt buộc triệt tiêu giao diện cẩu thả, rẻ tiền (AI Slop UI) và cấm tuyệt đối việc dùng Emoji thay cho Icon chuyên nghiệp.

---

## 1. Chính Sách Tuyệt Đối Cấm Emoji Làm Icon (Zero-Emoji Policy)

### ⛔ CẤM TUYỆT ĐỐI:
- Không được dùng bất kỳ emoji Unicode nào (`🚀`, `✨`, `💡`, `🔥`, `🎉`, `⚡`, `📊`, `⚙️`, `🤖`, `👉`, v.v.) làm icon cho:
  - Nút bấm (Button)
  - Thẻ tính năng (Feature Card / Card Header)
  - Thanh điều hướng (Navbar / Sidebar Items)
  - Huy hiệu trạng thái (Status Badges / Tags)
  - Thông báo (Alerts / Banners)
- *Lý do*: Lạm dụng emoji biến phần mềm thành đồ chơi, mang lại cảm giác cẩu thả, thiếu đầu tư và sặc mùi "AI demo generated".

### ✅ BẮT BUỘC: Sử dụng Thư viện SVG Icon Chuyên nghiệp
Mọi icon trong giao diện bắt buộc phải là vector icon thực thụ từ các bộ thư viện tiêu chuẩn:
- **React / Next.js**: `lucide-react` (Ưu tiên số 1), `@heroicons/react`, hoặc `@radix-ui/react-icons`.
- **Vue / Nuxt**: `lucide-vue-next`.
- **Icon Sizing & Styling**:
  - Kích thước icon phải tương xứng với typography: `w-4 h-4` cho button nhỏ/badge, `w-5 h-5` cho body/nav, `w-6 h-6` cho card hero.
  - Áp dụng độ mờ hài hòa: `text-zinc-400 group-hover:text-zinc-100 transition-colors`.

---

## 2. Triệt Tiêu "Purple AI Slop" — Bảng Màu Cao Cấp (High-End Palette)

### ⛔ Cấm mẫu màu rập khuôn:
- Cấm dùng nền gradient tím - xanh mặc định của AI: `bg-gradient-to-r from-purple-500 to-indigo-600` hoặc `from-violet-600 to-fuchsia-600`.
- Cấm lạm dụng viền phát sáng lòe loẹt (`border-purple-500/50 shadow-purple-500/50 blur-3xl`).

### ✅ Bảng màu chuẩn mực (Tailwind Neutral / Slate Standards):
- **Dark Mode (Default of Modern Dev Tools)**:
  - Nền chính (Canvas): Neutral Zinc `bg-zinc-950` (`#09090b`) hoặc Slate Deep `bg-slate-950` (`#020617`).
  - Nền bề mặt (Surface/Card): `bg-zinc-900/50` hoặc `bg-zinc-900/80` kèm viền siêu mảnh `border border-zinc-800` hoặc `border-white/10`.
  - Phân cấp màu chữ:
    - Tiêu đề chính (Primary Text): `text-zinc-100` (`font-semibold tracking-tight`).
    - Nội dung phụ (Muted Text): `text-zinc-400` (`text-sm leading-relaxed`).
    - Nhãn mờ (Subtle / Metadata): `text-zinc-500` (`text-xs font-mono`).
- **Accent Color (Màu nhận diện duy nhất)**:
  - Chỉ chọn 1 màu điểm nhấn duy nhất cho toàn bộ sản phẩm:
    - Electric Indigo: `text-indigo-400`, `bg-indigo-600 hover:bg-indigo-500`
    - Emerald Green: `text-emerald-400`, `bg-emerald-600`
    - Warm Amber: `text-amber-400`, `bg-amber-600`
    - High-Tech Cyan: `text-cyan-400`, `bg-cyan-600`

---

## 3. Nhịp Điệu Bố Cục (Layout Rhythm) & Cấm Lồng Hộp Quá Đà

### ⛔ Cấm bệnh "Cards inside Cards inside Cards":
- Không bọc mọi thứ trong hộp viền vuông liên tiếp. Việc lạm dụng thẻ lồng nhau làm giao diện chật chội và ngột ngạt.

### ✅ Phân cách bằng Không Gian Trắng (Whitespace & Hierarchy):
1. **Hệ thống khoảng cách 8-Point Grid**:
   - Khoảng cách giữa các phần tử liên quan: `gap-2` (8px), `gap-3` (12px), `gap-4` (16px).
   - Padding bên trong card: `p-5` hoặc `p-6` (20px - 24px).
   - Khoảng cách giữa các section: `py-12` hoặc `py-16` (48px - 64px).
2. **Đường phân cách tinh tế (Subtle Dividers)**:
   - Sử dụng `border-t border-zinc-800/80` hoặc sự chuyển sắc độ nhẹ giữa các vùng bề mặt thay vì vẽ khung hộp dày cộp.
3. **Typography Scale**:
   - Sử dụng font chữ hiện đại (Geist Sans, Inter, Plus Jakarta Sans).
   - Tiêu đề lớn (Display): Phải luôn có `tracking-tight` (`tracking-[-0.02em]`) để chữ không bị loãng.

---

## 4. Kiểm Thử Trực Quan Trước Khi Bàn Giao (Visual Verification)

Trước khi nghiệm thu bất kỳ component UI nào:
1. **Kiểm tra độ tương phản (Contrast Check)**: Đảm bảo chữ nhỏ trên nền tối luôn đọc được rõ ràng (WCAG AA standard).
2. **Kiểm tra Hover / Focus States**: Mọi button, link, input đều phải có hiệu ứng mượt mà khi hover (`transition-all duration-150 active:scale-[0.98]`).
3. **Kiểm tra Responsive**: Component phải co giãn mượt mà từ màn hình Mobile (375px) đến Desktop (1440px), không được để tràn ngang (`overflow-x-hidden`).
