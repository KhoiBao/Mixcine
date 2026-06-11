# BÁO CÁO TIẾN ĐỘ PHÁT TRIỂN HỆ THỐNG XÁC THỰC VÀ CƠ SỞ DỮ LIỆU CỤC BỘ
## DỰ ÁN: MIXCINE MOVIE APP

---

### I. THÔNG TIN TỔNG QUAN
* **Dự án:** Mixcine Movie App.
* **Kiến trúc áp dụng:** Clean Architecture.
* **Thành phần tập trung xử lý:** Quản lý User (Authentication) và Đồng bộ Dữ liệu cục bộ (Local Database - SQLite).

---

### II. NỘI DUNG VÀ CÁC BƯỚC ĐÃ THỰC HIỆN

#### 1. Nâng cấp Hệ thống Cơ sở dữ liệu Cục bộ (SQLite)
* **Chuẩn hóa Schema (`database_helper.dart`):** Cập nhật lên Version 3 để hỗ trợ đầy đủ tính năng đa người dùng.
  * **Bảng `favorites`:** Giữ nguyên cấu trúc, đã tối ưu ràng buộc `UNIQUE(user_id, movie_id)`.
  * **Bảng `watch_history`:** Bổ sung trường `user_id` và `updated_at` (chuỗi ISO8601).
  * **Bảng `reviews`:** Mở rộng toàn diện với các trường `user_id`, `author_name`, `comment`, `rating`, và `created_at`.
* **Đồng bộ hóa Data Models & Data Sources:**
  * Cập nhật `WatchHistoryModel` và `ReviewModel` để bao hàm các trường định danh mới.
  * Sửa đổi các file Local Data Source tương ứng (như `WatchHistoryLocalDataSource` và `ReviewLocalDataSource`) để yêu cầu truyền các tham số định danh (`userId`, `authorName`) từ tầng trên xuống, đồng thời tự động sinh nhãn thời gian thực (`DateTime.now()`) khi thực hiện thao tác lưu/thêm mới.
* **Cập nhật Repository Interfaces & Impl:** Hiệu chỉnh toàn bộ tầng kết nối trung gian (như `WatchHistoryRepositoryImpl` và `ReviewRepositoryImpl`) để đảm bảo quá trình truyền dẫn dữ liệu từ Use Case xuống Data Source diễn ra chính xác với bộ tham số mới.

#### 2. Tái cấu trúc Hệ thống Xác thực (Authentication)
* **Định hướng Kỹ thuật:** Quyết định không thiết lập bảng `users` trong SQLite mà chuyển hướng tích hợp trực tiếp **Firebase Authentication** để tối ưu hóa quy trình quản lý phiên làm việc và bảo mật thông tin.
* **Tầng Domain (Định nghĩa Nghiệp vụ):**
  * Xây dựng Interface `AuthRepository` định nghĩa các hợp đồng cơ bản: `login`, `getCurrentUser`, và `logout`.
  * Triển khai mô hình Facade: Gộp các Use Case xác thực nhỏ lẻ thành một lớp điều phối duy nhất `AuthUseCases` (`lib/domain/usecases/auth_usecases.dart`) nhằm tinh gọn mã nguồn, giảm số lượng file (Boilerplate code) nhưng vẫn đảm bảo tính tách biệt rạch ròi của kiến trúc.
* **Tầng Data (Triển khai Kết nối):**
  * Xây dựng `AuthRemoteDataSource` tích hợp thư viện `firebase_auth`, cung cấp các phương thức tương tác trực tiếp với Firebase Backend (đăng nhập bằng Email/Password, truy xuất người dùng hiện tại, đăng xuất).
  * Khởi tạo `AuthRepositoryImpl` chịu trách nhiệm giao tiếp giữa Domain và Firebase Data Source. Lớp này đảm bảo tính nhất quán bằng cách ánh xạ (Map) đối tượng `firebase.User` thô thành đối tượng `User` chuẩn (Entity) của dự án, đồng thời tận dụng chuỗi `uid` cực kỳ bảo mật từ Firebase làm khóa ngoại liên kết (user_id) cho hệ thống SQLite.
* **Cấu hình Nền tảng:** Khai báo tích hợp thư viện Firebase Core/Auth và thiết lập lệnh khởi tạo `Firebase.initializeApp()` tại hàm `main()` để hệ thống sẵn sàng vận hành.

---

### III. KẾT LUẬN & ĐÁNH GIÁ
* Mọi tiến trình từ khâu chuẩn hóa thiết kế bảng, phân luồng tham số cho đến thiết lập bộ khung xác thực người dùng bằng Firebase đã được triển khai đồng bộ và triệt để theo đúng nguyên lý Clean Architecture.
* Việc áp dụng UID từ Firebase vào hệ thống SQLite giúp Mixcine giải quyết hoàn toàn bài toán phân tách dữ liệu cho nhiều tài khoản trên cùng một thiết bị một cách nhẹ nhàng và bảo mật nhất.

---
*Báo cáo được tổng hợp tự động dựa trên tiến độ phiên làm việc ngày 09/06/2026.*
