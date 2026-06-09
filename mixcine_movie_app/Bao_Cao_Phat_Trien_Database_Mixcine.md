# BÁO CÁO TIẾN ĐỘ PHÁT TRIỂN HỆ THỐNG CƠ SỞ DỮ LIỆU CỤC BỘ (LOCAL DATABASE)
## DỰ ÁN: MIXCINE MOVIE APP

---

### I. THÔNG TIN TỔNG QUAN
* **Dự án:** Mixcine Movie App (Ứng dụng xem phim demo phát triển bằng Flutter & Dart).
* **Kiến trúc áp dụng:** Clean Architecture (Core, Data, Domain, Presentation).
* **Quản lý trạng thái (State Management):** Riverpod.
* **Thành phần tập trung xử lý:** Tầng Dữ liệu cục bộ (Local Database - SQLite).

---

### II. NỘI DUNG VÀ CÁC BƯỚC ĐÃ THỰC HIỆN

#### 1. Rà soát Kiến trúc & Cấu trúc Thư mục
* Đối chiếu cấu trúc thư mục hiện tại của dự án với thiết kế tổng quan trong file `README.md`.
* **Ghi nhận:** Các tầng cốt lõi (`data`, `domain`, `core`, `presentation`) được tổ chức bài bản. Thư mục `database` chứa helper hiện đang đặt tại thư mục gốc của `lib` (hướng tối ưu tiếp theo là di chuyển vào trong `core/services` hoặc `data/datasources` để đạt độ chuẩn hóa cao nhất theo kiến trúc Clean Architecture).

#### 2. Chuẩn hóa Schema Cơ sở dữ liệu (`database_helper.dart`)
* Thực hiện nâng cấp cơ sở dữ liệu SQLite từ **Version 1/2 lên Version 3**.
* Rà soát và mở rộng các cột dữ liệu (Schema) để giải quyết triệt để bài toán **Đa người dùng (Multi-user)** và **Mốc thời gian thực (Timestamp)**.
* Cấu trúc 03 bảng dữ liệu hoàn chỉnh sau khi rà soát:
  * **`favorites` (Danh sách yêu thích):** Lưu `user_id`, `movie_id` với ràng buộc `UNIQUE(user_id, movie_id)` để tránh trùng lặp dữ liệu thả tim.
  * **`watch_history` (Lịch sử xem phim):** Bổ sung `user_id` và `updated_at` (TEXT - định dạng ISO8601) giúp quản lý tiến độ xem riêng biệt cho từng tài khoản và hỗ trợ sắp xếp phim mới xem lên đầu danh sách.
  * **`reviews` (Đánh giá/Bình luận):** Bổ sung đầy đủ các trường thông tin tác giả gồm `user_id`, `author_name`, `comment`, `rating`, và `created_at` phục vụ hiển thị chi tiết trên giao diện.

#### 3. Đồng bộ hóa Tầng Dữ liệu (Data Models)
* Tiến hành cập nhật cấu trúc mã nguồn của hai file Model cốt lõi để khớp nối chính xác với Schema database mới:
  * **`WatchHistoryModel`:** Thêm trường `userId` và `updatedAt`, hoàn thiện các hàm `toMap()` và `fromMap()`.
  * **`ReviewModel`:** Thêm trường `userId`, `authorName`, và `createdAt`, hoàn thiện logic map dữ liệu để chuyển đổi mượt mà giữa đối tượng Dart và các dòng lệnh trong SQLite.

#### 4. Xây dựng các Lớp Phục vụ Truy vấn (Local Data Sources)
* Tạo mới và hoàn thiện các lớp Data Source chuyên biệt chịu trách nhiệm thực thi câu lệnh SQL:
  * **`WatchHistoryLocalDataSource`:** Tích hợp thuật toán `ConflictAlgorithm.replace` trong lệnh `insert`. Đảm bảo khi người dùng xem tiếp một bộ phim, tiến độ mới sẽ tự động ghi đè lên tiến độ cũ một cách tối ưu.
  * **`ReviewLocalDataSource`:** Triển khai các hàm thêm đánh giá (`addReview`), lấy danh sách đánh giá theo ID phim (`getReviewsForMovie`) sắp xếp theo thời gian mới nhất, và xóa đánh giá.

#### 5. Triển khai Kịch bản Kiểm thử Cơ sở dữ liệu (`testDatabase`)
* Thiết lập một hàm kiểm thử ngầm `testDatabase()` trong `main.dart` để tự động hóa quy trình cô lập lỗi mà không cần thông qua giao diện UI:
  * Giả lập một tiến trình thêm dữ liệu Yêu thích cho tài khoản test.
  * Giả lập tiến trình xem phim hai lần liên tiếp (Lần 1: 45 phút, Lần 2: 120 phút) để kiểm tra tính năng ghi đè tiến độ xem.
  * Giả lập viết một bình luận phim mới.
* **Kết quả nghiệm thu qua Debug Console:** Hệ thống SQLite khởi tạo và thực thi thành công 100%. Ràng buộc `UNIQUE` hoạt động chính xác, dữ liệu in ra đúng kỳ vọng, không xảy ra bất kỳ xung đột cấu trúc nào.

---

### III. KẾT LUẬN VỀ KIẾN TRÚC HỆ THỐNG USER
* **Đánh giá bảng `users` cục bộ:** Qua phân tích luồng vận hành, việc xây dựng một bảng `users` riêng biệt trong SQLite là **không cần thiết** cho quy mô hiện tại của ứng dụng Mixcine.
* **Giải pháp tối ưu đã thống nhất:** Thông tin tài khoản người dùng và phiên đăng nhập (Session) sẽ được quản lý tập trung qua Server/Auth Service và lưu trữ lưu động dưới máy bằng **`SharedPreferences`** (thư viện đã có sẵn trong Tech Stack của dự án). Các bảng dữ liệu cục bộ chỉ cần lưu trữ `user_id` dạng chuỗi làm định danh liên kết là hoàn toàn đủ điều kiện vận hành.

---

### IV. HƯỚNG ĐI TIẾP THEO (NEXT STEPS)
1. **Xóa/Comment hàm test:** Gỡ bỏ lệnh gọi `await testDatabase()` trong `main.dart` để ứng dụng quay lại luồng khởi động bình thường.
2. **Triển khai Tầng Domain (Use Cases):** Xây dựng các Use Cases còn thiếu cho phần Lịch sử xem và Đánh giá phim để kết nối dữ liệu từ Repository lên UI.
3. **Khai báo Riverpod Providers:** Thiết lập các StateNotifierProvider hoặc AsyncNotifierProvider để quản lý trạng thái luồng dữ liệu của Lịch sử xem phim và Đánh giá phim, sẵn sàng cung cấp dữ liệu sạch cho tầng Presentation vẽ giao diện.

---
*Báo cáo được tổng hợp tự động dựa trên tiến độ phiên làm việc ngày 09/06/2026.*
