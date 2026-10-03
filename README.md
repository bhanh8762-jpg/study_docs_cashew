# Quản lý Tài liệu Học tập – Kiến trúc Cashew (Flutter)

Ứng dụng Flutter quản lý **bài giảng, bài tập và tài liệu tham khảo**, tổ chức mã nguồn theo cách
của dự án mã nguồn mở [Cashew](https://github.com/jameskokoska/Cashew): `database/`, `struct/`, `pages/` và `widgets/`.

## Chức năng
- Thêm, sửa, xóa tài liệu (tiêu đề, loại, môn học, đường dẫn, mô tả, thẻ)
- Tìm kiếm theo từ khóa (hỗ trợ tiếng Việt có dấu) và lọc theo loại
- Thống kê số tài liệu theo loại
- Dữ liệu được lưu lại sau khi đóng app (`shared_preferences`)

## Kiến trúc

```
lib/
├── main.dart          Composition Root – lắp ráp các lớp
├── database/          Dữ liệu: mô hình (tables.dart) + repository
├── struct/            Logic nghiệp vụ + quản lý trạng thái
├── pages/             Màn hình
└── widgets/           Thành phần giao diện tái sử dụng
```

Hướng phụ thuộc: `pages → struct → database`, và `widgets → database/tables.dart`.
Các quy tắc này được kiểm tra tự động trong `test/architecture_test.dart`.

Báo cáo và sơ đồ kiến trúc chi tiết: [docs/BAO_CAO.md](docs/BAO_CAO.md)

## Chạy bằng VS Code
1. Cài extension **Flutter** (VS Code sẽ gợi ý khi mở thư mục).
2. `File → Open Folder…` → chọn thư mục `study_docs_cashew`.
3. Mở terminal: `flutter pub get`.
4. Nhấn **F5** rồi chọn cấu hình **Chạy app (Chrome)** hoặc **Chạy app (Windows)**.
   - Chạy bản Windows cần bật *Developer Mode*: `start ms-settings:developers`.

## Chạy bằng dòng lệnh

```bash
flutter pub get
flutter run -d chrome
flutter test
```

## GitHub
Mỗi lần push, GitHub Actions (`.github/workflows/flutter.yml`) sẽ tự chạy `flutter analyze` và `flutter test`.
