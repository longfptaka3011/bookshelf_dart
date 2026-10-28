# Hướng dẫn Hoàn thiện & Nộp bài PRM393 - BookShelf (Fall 2026)

## 1. Triển khai Firebase Console & Test Account
1. **Firebase Authentication:**
   - Mở Firebase Console -> Project của bạn -> **Authentication** -> **Sign-in method**.
   - Bật provider **Email/Password**.
   - Tab **Users**: Nhấn **Add user** để tạo tài khoản test cho Giám khảo chấm bài:
     - **Email:** `grader.<MãSV>@example.com` (ví dụ: `grader.qe200012@example.com`)
     - **Password:** `Test1234!`
2. **Cloud Firestore Database:**
   - Tạo Firestore Database ở chế độ Production hoặc Test mode.
   - Tab **Rules**: Copy toàn bộ nội dung trong file [firestore.rules](firestore.rules) vào và nhấn **Publish**.
3. **Cấu hình Client-side (chọn 1 trong 2 cách):**
   - **Cách 1 (Khuyên dùng):** Tải file `google-services.json` từ Firebase Console (Project Settings -> Your Android app) và đặt vào thư mục `android/app/google-services.json`.
   - **Cách 2:** Mở file [lib/firebase_options.dart](lib/firebase_options.dart) và cập nhật `apiKey`, `appId`, `projectId`, `messagingSenderId` của Android App từ Firebase Console.

---

## 2. Thứ tự 16 Ảnh Chụp Màn hình Cần Đưa vào File `<StudentCode>.docx`
Mỗi ảnh chụp phải được chụp từ thiết bị thật hoặc máy ảo (emulator) đang đăng nhập bằng tài khoản test của bạn, kèm đúng caption như dưới đây:

| STT | Tên Caption Chuẩn | Mô tả chi tiết hình ảnh cần chụp |
|---|---|---|
| 1 | `Firebase console — Authentication` | Danh sách Users trong Firebase Console hiển thị tài khoản test của giám khảo. |
| 2 | `Firebase console — Firestore data` | Collection `books` hiển thị ít nhất 3 documents thuộc tài khoản test. |
| 3 | `Firebase console — Security Rules` | Tab Rules trong Firebase Console hiển thị các rules đã được **Publish**. |
| 4 | `Register screen — validation` | Form Register submit khi để trống, hiển thị các thông báo lỗi màu đỏ dưới từng ô. |
| 5 | `Register screen — success` | Ngay sau khi đăng ký thành công, hiển thị thông báo `Registration successful`. |
| 6 | `Login screen` | Màn hình Login với form đăng nhập trống. |
| 7 | `List screen — after login` | Màn hình List sau khi đăng nhập, hiển thị email người dùng ở header, nút Logout và ít nhất 3 cuốn sách. |
| 8 | `Add Book form — validation` | Form Add Book submit khi để trống/nhập sai, hiển thị các thông báo lỗi dưới từng trường. |
| 9 | `Add Book form — success` | Ngay sau khi thêm sách thành công, hiển thị `Book added` và cuốn sách mới xuất hiện ngay trên danh sách. |
| 10 | `Filters and search` | Bộ lọc thể loại, trạng thái, switch favorites-only và ô tìm kiếm thay đổi danh sách hiển thị. |
| 11 | `Summary` | Hiển thị `Books: N`, `Favorites: N` và bảng phân loại trạng thái có ít nhất 2 trạng thái. |
| 12 | `Detail screen — view mode` | Xem chi tiết 1 cuốn sách: Title, Author, Genre, Status, Rating, Notes và ngôi sao Favorite. |
| 13 | `Detail screen — edit mode, validation` | Chế độ Edit submit khi nhập sai dữ liệu, hiển thị các thông báo lỗi. |
| 14 | `Detail screen — after Save` | Màn hình chi tiết sau khi bấm Save hiển thị các giá trị mới đã cập nhật. |
| 15 | `Favorite toggle and Delete` | Cặp ảnh trước/sau: Ngôi sao được toggle bật/tắt và cuốn sách bị xóa khỏi danh sách sau khi xác nhận dialog. |
| 16 | `Empty state` | Màn hình List hiển thị text `No books found` (chụp khi đăng nhập tài khoản mới chưa có sách). |

---

## 3. Template Bảng Thông tin Trong File `<StudentCode>.docx`
Copy bảng dưới đây vào file Word và điền đầy đủ thông tin:

| Trường thông tin | Giá trị của bạn |
|---|---|
| **Student Code** | `QE200012` *(Thay bằng mã sinh viên thật)* |
| **Full Name** | `Nguyen Van A` *(Thay bằng họ và tên thật)* |
| **GitHub Repository URL** | `https://github.com/<username>/<repo-name>` |
| **APK Download Link** | `https://github.com/<username>/<repo-name>/releases/download/v1.0/app-release.apk` *(Hoặc link Google Drive công khai)* |
| **Firebase Project ID** | `<your-firebase-project-id>` |
| **Test account email** | `grader.<student_code>@example.com` |
| **Test account password** | `Test1234!` |

---

## 4. Build Release APK & Đóng gói Code
1. **Build Release APK:**
   ```bash
   flutter build apk --release
   ```
   File APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`.
   Upload file này lên **GitHub Releases** hoặc **Google Drive** (chọn chế độ "Bất kỳ ai có liên kết đều có thể xem/tải").
2. **Đóng gói mã nguồn sạch `<StudentCode>.zip`:**
   Chạy script tự động có sẵn:
   ```bash
   python package_submission.py <StudentCode>
   ```
   (Ví dụ: `python package_submission.py QE200012`)
   Script sẽ tự động nén đúng cấu trúc, loại bỏ toàn bộ `build/`, `.dart_tool/`, `.git/` và kiểm tra bảo mật không để lọt Service Account key.
3. **Thư mục nộp bài:**
   Tạo thư mục tên `<StudentCode>` chứa đúng 2 file:
   - `<StudentCode>.docx`
   - `<StudentCode>.zip`

