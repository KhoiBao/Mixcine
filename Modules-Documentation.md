# EDUX Platform - Tài Liệu Chi Tiết Từng Module

> **Nền tảng:** ASP.NET Core 8.0 Web API | **Database:** SQL Server | **Cache:** Redis | **DI:** Autofac | **ORM:** EF Core 8.0

---

## Mục Lục

1. [Tổng Quan Kiến Trúc](#1-tổng-quan-kiến-trúc)
2. [Gateway - API Gateway](#2-gateway---api-gateway)
3. [AuthenAPI - Xác Thực & Phân Quyền](#3-authenapi---xác-thực--phân-quyền)
4. [StudentHub - Quản Lý Sinh Viên](#4-studenthub---quản-lý-sinh-viên)
5. [AdmissionManagement - Quản Lý Tuyển Sinh](#5-admissionmanagement---quản-lý-tuyển-sinh)
6. [SystemManagement - Quản Trị Hệ Thống](#6-systemmanagement---quản-trị-hệ-thống)
7. [TrainningProgram - Chương Trình Đào Tạo](#7-trainningprogram---chương-trình-đào-tạo)
8. [PaymentHub - Thanh Toán](#8-paymenthub---thanh-toán)
9. [CdnHub - Quản Lý File & Tài Liệu](#9-cdnhub---quản-lý-file--tài-liệu)
10. [CommonLibraries - Thư Viện Dùng Chung](#10-commonlibraries---thư-viện-dùng-chung)
11. [Hướng Dẫn Cho Người Mới](#11-hướng-dẫn-cho-người-mới)

---

## 1. Tổng Quan Kiến Trúc

EDUX là một nền tảng quản lý giáo dục theo kiến trúc **microservices**, gồm 8 module độc lập giao tiếp qua API Gateway. Mỗi module tuân theo kiến trúc phân lớp:

```
┌─────────────────────────────────────────────────┐
│                 API Gateway (Ocelot)             │
│              Cổng duy nhất cho client             │
└──────────────┬──────────────────────────────────┘
               │ Routing theo prefix
    ┌──────────┼──────────┬──────────┬──────────┬──────────┐
    ▼          ▼          ▼          ▼          ▼          ▼
  Authen    Student   Admission  System   Training  Payment
   API       Hub       Mgmt      Mgmt     Program    Hub
    │          │          │          │          │          │
    └──────────┴──────────┴──────────┴──────────┴──────────┘
                              │
                            CdnHub
                    (Quản lý file & tài liệu)
```

### Kiến Trúc Mỗi Module (7 lớp)

```
Presentation.[Module].Api/          # Lớp Web API - Controllers, Program.cs
Presentation.Services/              # Lớp Business Logic - Xử lý nghiệp vụ
Presentation.Repository/            # Lớp Data Access - Repository + UnitOfWork
Presentation.Models/                # DTOs, ViewModels, Request/Response
Presentation.Context/               # EF Core DbContext & Entity Configurations
Presentation.Common/                # Constants, Enums, Shared Utilities
Presentation.Extensions/            # DI Modules, AutoMapper, Middleware
```

### Công Nghệ Chung
| Thành phần | Công nghệ |
|-----------|-----------|
| Framework | ASP.NET Core 8.0 |
| Database | SQL Server (EF Core 8.0) |
| Cache | Redis (StackExchange) |
| DI Container | Autofac |
| Object Mapping | AutoMapper |
| Authentication | JWT Bearer + ASP.NET Core Identity |
| API Documentation | Swagger/OpenAPI (Swashbuckle) |
| Testing | xUnit + Moq |
| CI/CD | GitLab CI |

---

## 2. Gateway - API Gateway

**Đường dẫn:** `Gateway/APIGW/`
**Framework:** Ocelot 20.0.0
**Port:** Không cố định (gateway là điểm vào duy nhất)

### Vai Trò
Gateway đóng vai trò **cổng vào duy nhất** cho toàn bộ hệ thống. Client chỉ cần gọi đến gateway, gateway sẽ tự động chuyển tiếp request đến module tương ứng.

### Bảng Routing

| Prefix URL | Module đích | Downstream URL |
|-----------|-------------|----------------|
| `/auth/*` | AuthenAPI | `localhost:7002` |
| `/system-admin/*` | SystemManagement | `localhost:7003` |
| `/student-portal/*` | AdmissionManagement | `localhost:7004` |
| `/trainning-program/*` | TrainningProgram | `localhost:7005` |
| `/student-hub/*` | StudentHub | `localhost:7006` |
| `/payment-hub/*` | PaymentHub | `localhost:7007` |
| `/cdn-hub/*` | CdnHub | `localhost:7008` |

### Middleware Pipeline
1. **CORS** - Cho phép mọi origin (development)
2. **Swagger** - Tài liệu API tổng hợp từ tất cả module
3. **RequestLimitingMiddleware** - Chống trùng lặp request concurrent (chỉ áp dụng cho `/frontend/*`)
4. **SwaggerForOcelotUI** - Giao diện Swagger UI tổng hợp
5. **Ocelot Routing** - Engine định tuyến chính

### Tính Năng Đặc Biệt
- **Request Deduplication:** Nếu có nhiều request giống hệt nhau đang xử lý concurrent, chỉ request đầu tiên được gửi xuống downstream, các request còn lại chờ và nhận kết quả từ cache
- **Circuit Breaker (Polly):** Sau 2 lỗi liên tiếp, circuit mở trong 5 giây, request thất bại nhanh
- **Structured Logging (Serilog → Elasticsearch):** Mọi request được log với thời gian phản hồi, status code, response body (nén base64)
- **Swagger Aggregation:** Tự động gom Swagger docs từ tất cả 7 microservices vào 1 giao diện duy nhất

### Lưu Ý Quan Trọng
- **Không có authentication tại gateway** - Xác thực được ủy thác cho downstream services
- **Rate limiting bị tắt** ở cấp Ocelot (chỉ có deduplication)
- **Caching bị tắt** (TtlSeconds = 0)
- File cấu hình route: `Routes/ocelot.webapi.json`

---

## 3. AuthenAPI - Xác Thực & Phân Quyền

**Đường dẫn:** `AuthenAPI/AuthenModule/`
**Solution:** `Presentation.Authorize.Api.sln`

### Vai Trò
Module chịu trách nhiệm **xác thực người dùng, quản lý token, phân quyền, và social login**. Đây là module đầu tiên client tương tác khi đăng nhập.

### Controllers & Endpoints Chính

#### AccountController (`/api/Account/*`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/Register` | POST | Đăng ký user mới, tự gán role "User" |
| `/Login` | POST | Đăng nhập (username/email/phone + password). Hỗ trợ fallback sang database HR cũ |
| `/RefreshToken` | POST | Làm mới access token từ refresh token |
| `/ForgotPassword` | POST | Gửi email đặt lại mật khẩu |
| `/ResetPassword` | POST | Đặt lại mật khẩu với token |
| `/ChangePassword` | PUT | Đổi mật khẩu (yêu cầu auth) |
| `/OTPUserInfo` | PUT | Gửi OTP đến email mới để xác thực |
| `/UpdateUserInfo` | PUT | Cập nhật thông tin sau khi xác thực OTP |
| `/UpdateProfile` | PUT | Cập nhật họ tên, giới tính, avatar (upload lên CDN) |
| `/GetProfile` | GET | Lấy thông tin profile + menu permissions |
| `/Logout` | GET | Đăng xuất, thu hồi tất cả token |
| `/ConnectGoogle` | GET | Kết nối tài khoản Google OAuth2 |
| `/SignInWithGoogle` | GET | Đăng nhập bằng Google |
| `/SignInWithMicrosoft` | GET | Kết nối Microsoft OAuth2 |

#### Permission Controllers
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `MenuManagementController` | `/api/MenuManagement` | Quản lý menu điều hướng |
| `GroupUserController` | `/api/GroupUser` | Quản lý nhóm người dùng |
| `GroupPermissionMenuController` | `/api/GroupPermissionMenu` | Quản lý quyền theo nhóm |
| `UserPermssionMenuController` | `/api/UserPermssionMenu` | Quản lý quyền theo user |

#### NotificationController
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/SendDeployNotify?content=` | GET | Gửi thông báo deploy lên Discord webhook |

### Cơ Chế Xác Thực

#### JWT Token Flow
```
1. Client gửi Login(username, password)
2. Server xác thực qua ASP.NET Core Identity
3. Tạo JWT Access Token (HMAC-SHA256, expiry 120 phút)
   - Claims: UserName, FullName, userid, Data (encrypted cache key)
   - Menu permissions được mã hóa và lưu trong cache, key đặt vào claim "Data"
4. Tạo Refresh Token (32 bytes random, encrypted)
5. Lưu cả 2 token vào database (UserAccessTokens, UserRefreshTokens)
6. Trả về cho client
```

#### Token Validation
Mỗi request có JWT, server kiểm tra:
1. Token có tồn tại trong database không?
2. Token có bị thu hồi (revoked) không?
3. Token có hết hạn không?

#### Social Login
- **Google OAuth2:** 2 flow - "Connect" (gán vào tài khoản hiện có) và "Sign In" (đăng nhập trực tiếp)
- **Microsoft OAuth2:** Tương tự Google
- Cookie authentication được dùng cho OAuth2 flow

### Database
| Context | Connection | Mô tả |
|---------|------------|-------|
| `UApplicationIdentity` | `DbConnection` | ASP.NET Core Identity (Users, Roles) |
| `EDuXDBContext` | `DbConnection` | Business data chính |
| `EduX_HRMContext` | `EduX_HRM` | Database HR cũ (fallback login, MD5 passwords) |

### Phân Quyền
- **`[EdotAuth]`** - Custom attribute từ `GeneralExtensions`, kiểm tra claim/scope
- **`[EdotAuth([ActionEnum.View])]`** - Kiểm tra quyền chi tiết (View, Create, Update)
- **Policy "AdminRole"** - Yêu cầu claim `isAdmin = true`

---

## 4. StudentHub - Quản Lý Sinh Viên

**Đường dẫn:** `StudentHub/studenthubmodule/`
**Solution:** `Presentation.StudentHubModule.Api.sln`

### Vai Trò
Module **quản lý vòng đời sinh viên** từ khi trúng tuyển đến khi ghi danh, bao gồm: xác thực thông tin, tạo booking khóa học, quản lý hồ sơ tài liệu, xuất thẻ sinh viên PDF, và thống kê.

### Controllers & Endpoints

#### AuthController (`/api/Auth`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/Login` | POST | Đăng nhập sinh viên |
| `/ForgotPasswordSV` | POST | Gửi email đặt lại mật khẩu (HTML template) |
| `/ResetPasswordSV` | POST | Đặt lại mật khẩu với token từ cache |
| `/ResetPasswordSVAdmin` | POST | Admin reset mật khẩu sinh viên trực tiếp |
| `/Logout` | POST | Đăng xuất |

#### StudentController (`/api/Student`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/VerifyUserInfo` | POST | Xác thực sinh viên (CMND + Họ tên + Ngày sinh) |
| `/GetStudentInfo?sessionId=` | GET | Lấy thông tin sinh viên đầy đủ theo session |
| `/GetBaseInfoByToken` | GET | Lấy thông tin cơ bản từ link email |
| `/ConfirmStudent` | GET | Xác nhận nhập học + tạo booking tự động |
| `/CreateUser` | GET | Tạo tài khoản Identity cho sinh viên trúng tuyển |
| `/GetUserActives` | GET | Danh sách user sinh viên đang hoạt động |
| `/GetUserById` | GET | Lấy thông tin chi tiết user |
| `/UpdateUserInfo` | PUT | Cập nhật profile sinh viên (bao gồm upload avatar lên CDN) |
| `/SyncInfoFromStudent` | GET | Đồng bộ thông tin từ bản ghi tuyển sinh |
| `/GetStudentDocuments/{studentId}` | GET | Danh sách hồ sơ yêu cầu và đã nộp |
| `/ExportGenerateStudentPdf` | POST | **Xuất thẻ sinh viên PDF** (xử lý ảnh + vẽ text) |
| `/PaginationFilter` | POST | Phân trang danh sách sinh viên trúng tuyển |

#### BookingController (`/api/Booking`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/GetBookingByCode/{code}` | GET | Lấy thông tin booking (validate token) |
| `/RecheckBooking/{bookingCode}` | GET | Kiểm tra trạng thái thanh toán (cache 30s) |

#### StatisticsController (`/api/statistics`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/students-by-major` | GET | Thống kê sinh viên theo ngành |
| `/student-status-all` | GET | Phân bố trạng thái sinh viên toàn trường |
| `/student-status-by-major` | GET | Phân bố trạng thái theo ngành |
| `/student-gender` | GET | Phân bố giới tính theo ngành |
| `/student-admission-profile` | GET | Trạng thái hồ sơ tuyển sinh theo ngành |

#### CRUD Controllers
- `AccCourseBookingDetailController` - Chi tiết booking khóa học
- `AccCourseBookingPaymentHistoryController` - Lịch sử thanh toán
- `AccCoursePricingController` - Bảng giá khóa học
- `STUDocumentSubmissionController` - Upload/download tài liệu sinh viên
- `ActDocumentSubmissionController` - Audit log tài liệu

### Tính Năng Nổi Bật

#### Xuất Thẻ Sinh Viên PDF
Đây là tính năng kỹ thuật phức tạp nhất module:
1. Lấy template ảnh mặt trước/sau từ CDN
2. Tự động scale template nếu nhỏ hơn 800px (x2)
3. Tải ảnh thẻ sinh viên, cắt và vẽ lên template tại tọa độ cố định
4. Vẽ thông tin (Họ tên, Ngày sinh, Ngành, Khóa, Mã SV) bằng font Roboto
5. Ghép 2 mặt thành 1 ảnh, chuyển sang PDF qua iText7
6. Trả về file PDF download

#### Course Booking Tự Động
Khi sinh viên xác nhận nhập học:
1. Tìm admission period detail phù hợp
2. Tìm training plan (ngành, campus, hệ đào tạo, khóa)
3. Lấy curriculum framework → danh sách môn theo học kỳ
4. Ghép với bảng giá theo loại môn học
5. Áp dụng phụ phí từ training plan
6. Sinh booking code (prefix + ID padding)

#### Quản Lý Tài Liệu
- Template hồ sơ xác định tài liệu cần nộp theo ngành/hệ đào tạo
- Upload file lên CDN Hub qua HTTP API
- Batch upload nhiều file cùng lúc
- Audit trail mọi thao tác tài liệu

### Database (3 databases)
| Context | Connection | Mô tả |
|---------|------------|-------|
| `EDuXDBContext` | `DbConnection` | Database chính - 60+ entity sets |
| `EntityStudentDbContext` | `EduX_Student` | Dữ liệu sinh viên - lecture groups, document submissions |
| `StudentIdentityContext` | `EduX_Student` | ASP.NET Core Identity cho sinh viên |

### Services (52+ services)
Mỗi entity có 1 service interface + implementation, kế thừa từ `EntityServices<T>`:
- `StudentStatisticsService` - Thống kê sinh viên
- `STUDocumentSubmissionService` - Quản lý tài liệu + CDN
- `FontService` - Load font Roboto cho PDF rendering
- `EmailService` - Gửi email SMTP với HTML template

---

## 5. AdmissionManagement - Quản Lý Tuyển Sinh

**Đường dẫn:** `AdmissionManagement/studentportalmodule/`
**Solution:** `studentportalmodule.sln`

### Vai Trò
Module **quản lý toàn bộ quy trình tuyển sinh**: quản lý đợt tuyển sinh, import danh sách thí sinh từ Excel, gửi email thông báo trúng tuyển, theo dõi audit log, và quản lý danh mục (ngành, campus, phương thức tuyển sinh).

### Controllers & Endpoints

#### ErmAdmitStudentController (`/api/ErmAdmitStudent`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `GET /` | GET | Danh sách thí sinh trúng tuyển (eager-load navigation) |
| `POST /PaginationFilter` | POST | Phân trang + tìm kiếm (lọc theo hệ đào tạo, tên) |
| `GET /{id}` | GET | Chi tiết thí sinh + 10 bản ghi hoạt động gần nhất |
| `POST /` | POST | Tạo thí sinh mới (validate điểm, tạo audit log) |
| `PUT /{id}` | PUT | Cập nhật thí sinh (diff-tracking, audit log) |
| `DELETE /{id}` | DELETE | Soft-delete thí sinh |
| `POST /SendAdmissionEmails` | POST | Gửi email thông báo trúng tuyển (async, fire-and-forget) |
| `POST /MigrateLegacyAcademicCohortData` | POST | Migration: điền AcademicCohortId cho dữ liệu cũ |

#### ErmAdmissionPeriodController (`/api/ErmAdmissionPeriod`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `GET /` | GET | Danh sách đợt tuyển sinh |
| `POST /PaginationFilter` | POST | Phân trang tìm kiếm |
| `POST /PaginationFilterYear` | POST | Phân trang lọc theo năm hiện tại |
| `GET /{id}` | GET | Chi tiết đợt tuyển sinh |
| `POST /` | POST | Tạo đợt tuyển sinh mới |
| `PUT /{id}` | PUT | Cập nhật đợt tuyển sinh |
| `DELETE /{id}` | DELETE | Soft-delete |

#### ErmAdmissionPeriodDetailController (`/api/ErmAdmissionPeriodDetail`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `GET /` | GET | Danh sách chi tiết đợt tuyển sinh |
| `POST /PaginationFilter` | POST | Phân trang tìm kiếm |
| `GET /{id}` | GET | Chi tiết |
| `POST /` | POST | Tạo mới (kiểm tra trùng) |
| `PUT /{id}` | PUT | Cập nhật (kiểm tra trùng) |
| `POST /CopyRecord/{id}` | POST | Sao chép bản ghi |
| `DELETE /{id}` | DELETE | Soft-delete |

#### ErmAdmissionHistoryImportController (`/api/ErmAdmissionHistoryImport`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `POST /ImportAdmitStudents` | POST | **Import Excel** - Parse file, tạo thí sinh, trả về file thành công/lỗi |
| `GET /DownloadSampleFile` | GET | Tải file Excel mẫu |
| `DELETE /{importId}` | DELETE | Xóa toàn bộ thí sinh import từ 1 file |
| `GET /GetImportUsers` | GET | Danh sách user đã thực hiện import |

#### Catalog Controllers
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `CatBranchController` | `/api/CatBranch` | Quản lý campus/branch (cấu trúc cây) |
| `CatAdmissionMethodController` | `/api/CatAdmissionMethod` | Phương thức tuyển sinh |
| `ActAdmitStudentController` | `/api/ActAdmitStudent` | Audit log hoạt động thí sinh |

### Pipeline Import Excel
```
1. Upload file Excel → lưu vào thư mục TaiLieu/
2. Đọc Excel bằng ExcelDataReader (tự detect header row)
3. Với mỗi dòng dữ liệu (22+ cột):
   - Mapping: mã hồ sơ, tên, giới tính, ngày sinh, dân tộc, điểm, ngành, v.v.
   - Chuẩn hóa tiếng Việt (bỏ dấu) để match dữ liệu tham chiếu
   - Validate FK (ngành, dân tộc, phương thức tuyển sinh phải tồn tại)
4. Tạo bản ghi ERM_AdmitStudent + ACT_AdmitStudent audit
5. Sinh file Excel thành công và lỗi bằng ClosedXML
6. Tạo bản ghi log import (tên file, số lượng thành công/lỗi, đường dẫn file)
```

### Trạng Thái Thí Sinh
| Trạng thái | Giá trị | Mô tả |
|-----------|---------|-------|
| `Initiated` | 0 | Mới tạo |
| `Printed` | 1 | Đã in giấy báo |
| `SentEmail` | 2 | Đã gửi email |
| `SentZaloOA` | 3 | Đã gửi Zalo OA |
| `PrintedError` | -1 | Lỗi in |
| `SentEmailError` | -2 | Lỗi gửi email |
| `SentZaloOAError` | -3 | Lỗi gửi Zalo |

### Database
| Context | Connection | Mô tả |
|---------|------------|-------|
| `EDuXDBContext` | `DbConnection` | Database chính - 30+ entity sets |
| `EduX_HRM` | External | Tham chiếu dữ liệu HR |
| `EduX_EDU` | External | Tham chiếu dữ liệu giáo dục |

---

## 6. SystemManagement - Quản Trị Hệ Thống

**Đường dẫn:** `SystemManagement/systemmodule/`
**Solution:** `Presentation.SystemManagement.API.sln`
**Tests:** `Presentation.SystemManagement.API.Tests/` (11 test classes)

### Vai Trò
Module **lớn nhất và toàn diện nhất** - quản lý mọi khía cạnh của hệ thống giáo dục: người dùng, phân quyền, môn học, giảng viên, lớp học, thời khóa biểu, quy chế đào tạo, bảng giá, đăng ký môn học, và hơn 80 controllers.

### Nhóm Controllers Chính

#### User & Permission Management
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `UserController` | `/api/User` | CRUD user, gán nhóm, đổi mật khẩu, upload avatar CDN |
| `MenuManagementController` | `/api/MenuManagement` | Quản lý menu điều hướng (cây parent-child) |
| `GroupUserController` | `/api/GroupUser` | Nhóm người dùng |
| `GroupPermissionMenuController` | `/api/GroupPermissionMenu` | Quyền menu theo nhóm |
| `UserPermssionMenuController` | `/api/UserPermssionMenu` | Quyền menu theo user |
| `FeatureMgmtController` | `/api/FeatureMgmt` | Quản lý feature (quyền hành động) |
| `MenuFeatureController` | `/api/MenuFeature` | Mapping menu-feature |
| `UserGroupPermissionController` | `/api/UserGroupPermission` | Mapping user-group-permission |

#### Academic Catalog
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `CatCourseController` | `/api/CatCourse` | Danh mục môn học |
| `CATMajorController` | `/api/CATMajor` | Danh mục ngành đào tạo |
| `CatKnowledgeBlockController` | `/api/CatKnowledgeBlock` | Khối kiến thức |
| `CatAcademicYearController` | `/api/CatAcademicYear` | Năm học |
| `CatAcademicCohortController` | `/api/CatAcademicCohort` | Khóa học (đợt tuyển sinh) |
| `CatEducationSystemController` | `/api/CatEducationSystem` | Hệ đào tạo (ĐH, CĐ) |
| `CatEducationSystemTypeController` | `/api/CatEducationSystemType` | Loại hệ đào tạo (Chính quy, Vừa làm vừa học) |

#### Staff Management
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `CatLecturerController` | `/api/CatLecturer` | Danh mục giảng viên (upload avatar CDN) |
| `CatAcademicDegreeController` | `/api/CatAcademicDegree` | Học vị (TS, ThS, GS, PGS) |
| `CatAcademicRankController` | `/api/CatAcademicRank` | Học hàm |
| `CatDepartmentController` | `/api/CatDepartment` | Khoa/Phòng ban |
| `CatPositionController` | `/api/CatPosition` | Chức vụ |

#### Class & Schedule Management
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `EduClassCourseController` | `/api/EduClassCourse` | Lớp học phần (tạo tự động LT+TH từ schedule) |
| `EduLectureGroupController` | `/api/EduLectureGroup` | Nhóm giảng (lớp thực hành) |
| `CatTimetableConfigurationController` | `/api/CatTimetableConfiguration` | Cấu hình thời khóa biểu |
| `CatClassRoomController` | `/api/CatClassRoom` | Phòng học |
| `CatWeeklyShiftController` | `/api/CatWeeklyShift` | Ca học theo tuần |
| `ScheduleBulkCreateController` | `/api/ScheduleBulkCreate` | Tạo thời khóa biểu hàng loạt |

#### Student Operations
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `StudentCourseRegistrationController` | `/api/StudentCourseRegistration` | Đăng ký môn học của sinh viên |
| `EduLectureGroupStudentController` | `/api/EduLectureGroupStudent` | Phân sinh viên vào nhóm giảng |

#### Academic Regulations
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `CatAcademicRegulationController` | `/api/CatAcademicRegulation` | Quy chế đào tạo |
| `CfgAcademicRegulationPolicyController` | `/api/CfgAcademicRegulationPolicy` | Chính sách quy chế + cảnh báo năm + hạ bậc xếp loại |
| `CfgScoreColumnConventionController` | `/api/CfgScoreColumnConvention` | Quy ước cột điểm |

#### Financial Management
| Controller | Route | Mô tả |
|-----------|-------|-------|
| `AccCoursePricingController` | `/api/AccCoursePricing` | Bảng giá học phí |
| `AccCourseBookingController` | `/api/AccCourseBooking` | Booking khóa học |
| `CatSurchargeController` | `/api/CatSurcharge` | Phụ phí |

### Tính Năng Nổi Bật

#### Tạo Lớp Học Phần Tự Động
`EduClassCourseController.Create()` nhận schedule details và tự động:
1. Tạo lớp học phần Lý thuyết (LT) và Thực hành (TH)
2. Link với curriculum framework, training plan, phòng học
3. Tự tạo score permissions mặc định cho mỗi lớp
4. Validate với curriculum framework courses và học kỳ

#### Phân Lớp (Split Class)
`SplitMultipleAsync` cho phép chia 1 lớp học phần thành nhiều lớp nhỏ khi vượt sĩ số.

#### Score Permission Lifecycle
Khi trạng thái lớp học phần thay đổi:
- `ApprovedToOpen`, `Locked`, `WaitingForStudentRegistration` → kích hoạt score permissions
- `Planning`, `Cancelled` → vô hiệu hóa score permissions

### Database (5 contexts)
| Context | Connection | Mô tả |
|---------|------------|-------|
| `UApplicationIdentity` | `DbConnection` | ASP.NET Core Identity |
| `EDuXDBContext` | `DbConnection` | Database chính (60+ entities) |
| `EntityEDuXDBContext` | `DbConnection` | Extended context với audit tracking |
| `EntityStudentDbContext` | `EduX_Student` | Dữ liệu sinh viên |
| `EduX_EDU` | `EduX_EDU` | Dữ liệu giáo dục legacy |
| `EduX_HRM` | `EduX_HRM` | Dữ liệu HR legacy |

### Testing
Module có **11 test classes** sử dụng xUnit + Moq:
- `CatAcademicCohortControllerTest` - Full CRUD tests
- `MenuManagementControllerTest` - GetActive, GetMenu, GetById
- `EduClassCourseControllerTests` - UpdateStatus propagation
- `EduClassCourseScorePermissionControllerTest` - Log pagination, routing
- `CommonConstantTests` - Utility methods

---

## 7. TrainningProgram - Chương Trình Đào Tạo

**Đường dẫn:** `TrainningProgram/trainningprogrammodule/`
**Solution:** `Presentation.TrainningProgramModule.Api.sln`

### Vai Trò
Module **quản lý chương trình đào tạo và kế hoạch giảng dạy**: chương trình khung (curriculum framework), khối kiến thức, kế hoạch đào tạo, bảng giá môn học, xếp thời khóa biểu lớp học.

### Controllers & Endpoints

#### CurCurriculumFrameworkController (`/api/CurCurriculumFramework`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `GET /` | GET | Danh sách chương trình khung |
| `GET /{id}` | GET | Chi tiết (với cây nested đầy đủ: details → courses → knowledge blocks) |
| `POST /CreateFullFramework` | POST | Tạo chương trình khung đầy đủ với cây nested |
| `PUT /UpdateFullFramework` | PUT | Cập nhật đệ quy (tạo/cập nhật/xóa nested details & courses) |
| `GET /ExportCurCurriculumFrameworkWordById` | GET | **Xuất chương trình khung ra Word (.docx)** |
| `GET /CheckExistCode` | GET | Kiểm tra mã chương trình khung đã tồn tại |
| `DELETE /{id}` | DELETE | Soft-delete (cascade xóa child details & courses) |

#### CurTrainingProcessingController (`/api/CurTrainingProcessing`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `POST /CreateFull` | POST | Tạo lịch trình đào tạo tự động sinh daily schedule |

**Logic tự động sinh lịch:**
1. Sinh ngày cho phase đào tạo (training weeks)
2. Sinh ngày cho phase dự trữ (reserve weeks)
3. Sinh ngày cho phase thi (exam weeks)
4. Bỏ qua ngày lễ, đảm bảo bắt đầu từ thứ Hai

#### AccTrainingPlanController (`/api/AccTraningPlan`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `GET /` | GET | Danh sách kế hoạch đào tạo (với pricing & surcharge) |
| `GET /{id}` | GET | Chi tiết + tính tổng tiền |
| `POST /` | POST | Tạo kế hoạch (auto-map curriculum framework theo năm/học kỳ) |
| `GET /GetCoursesBySemesterWithPricing/{trainingPlanId}` | GET | Danh sách môn theo khối kiến thức kèm giá |

**Công thức tính học kỳ:**
```
SemesterIndex = (yearIndex - 1) * totalSemesterPerYear + semesterInYear
```

#### EduClassScheduleController (`/api/EduClassSchedule`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `POST /` | POST | Tạo lịch lớp (batch) |
| `POST /GetDailySchedule` | POST | Xem lịch theo ngày |
| `GET /GetAllClassCourseDetails/{id}` | GET | Chi tiết lớp học phần (parent + children) |

#### EduScheduleDetailController (`/api/EduScheduleDetail`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `POST /CreateOrUpdateOrDelete` | POST | Bulk tạo/cập nhật/xóa với **kiểm tra trùng phòng** |

**Kiểm tra trùng phòng:** Kiểm tra xem phòng học đã được đặt vào cùng ngày và khung giờ chưa.

### Services Đặc Biệt
| Service | Chức năng |
|---------|-----------|
| `CurCurriculumFrameworkService` | Quản lý chương trình khung, kiểm tra mã trùng |
| `CurTrainingProcessingService` | Tự sinh lịch đào tạo, tính toán ngày nghỉ lễ |
| `AccTrainingPlanService` | Kế hoạch đào tạo, merge pricing từ JSON, tính tổng tiền |
| `WordTableExporterService` | Xuất chương trình khung ra Word với merged headers, đánh số phân cấp (1, 1.1, 1.1.1) |
| `EduClassScheduleService` | Xếp lịch lớp học, sinh lịch daily view |

### Database
| Context | Connection | Mô tả |
|---------|------------|-------|
| `EDuXDBContext` | `DbConnection` | Database chính (60+ entities) |
| `EntityEDuXDBContext` | `DbConnection` | Extended context với audit tracking |
| `EntityStudentDbContext` | `EduX_Student` | Dữ liệu sinh viên |

---

## 8. PaymentHub - Thanh Toán

**Đường dẫn:** `PaymentHub/paymenthubmodule/`
**Solution:** `Presentation.PaymentHubModule.Api.sln`

### Vai Trò
Module **xử lý thanh toán học phí**, tích hợp cổng thanh toán **BaoKim.vn**, sinh mã **VietQR**, nhận SMS đối soát, và tự động ghi danh sinh viên vào lớp sau khi thanh toán thành công.

### Controllers & Endpoints

#### BaoKimController (`/api/BaoKim/*`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/ReturnSuccessBaokimUrl` | GET | OAuth callback sau khi thanh toán BaoKim |
| `/CheckIPNBaokim` | POST | **Webhook/IPN** - BaoKim gọi để thông báo trạng thái thanh toán |
| `/TestException` | GET | Test Discord logging |

#### QRController (`/api/QR/*`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/GetPaymentList` | GET | Danh sách phương thức thanh toán BaoKim |
| `/sendOrder` | GET | Gửi order lên BaoKim |
| `/GetBankList` | GET | Danh sách ngân hàng hỗ trợ VietQR |
| `/Generate` | GET | Sinh QR redirect qua BaoKim |
| `/GenerateV3` | POST | **Sinh QR chính** - Nhận booking code + token, tạo order BaoKim, trả thông tin ngân hàng |

#### SmsController (`/api/Sms/*`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/ReceiveSms` | POST | Nhận SMS từ EnvayaSMS, parse tin nhắn ngân hàng để đối soát |

### Payment Processing Pipeline
```
1. Client gọi QR/GenerateV3 với booking code
2. System fetch booking details từ StudentHub API
3. Tạo BaoKim order với mrc_order_id = {bookingCode}_{timestamp}
4. User thanh toán trên BaoKim
5. BaoKim gửi webhook → CheckIPNBaokim
6. System xác thực signature, tính phí, log payment
7. Cập nhật booking payment status (Paid/PartPaid)
8. Tạo/tìm user sinh viên từ CMND
9. Tự động ghi danh vào lớp phù hợp
```

### Tích hợp Thanh Toán

#### BaoKim.vn
- **API:** JWT authentication (HMAC-SHA256, 24h expiry)
- **Phương thức:** ATM nội địa, Visa/Master, chuyển khoản QR, ví điện tử (MoMo, Viettel Money, ZaloPay), trả góp
- **Phí tính từ `ACC_AddonServiceType`** theo loại phương thức (atm, visa, momo, default)

#### VietQR
- Sinh mã QR chuẩn EMV với TLV encoding
- CRC16-CCITT checksum
- Embed logo ngân hàng + branding VietQR
- Output: ảnh PNG

#### EnvayaSMS
- Nhận SMS từ thiết bị Android chạy EnvayaSMS
- Parse tin nhắn chuyển khoản (regex: `+1,234,567 VND`, mã `VG`/`BKG` + 9-12 số)
- TODO: Chưa cập nhật payment status từ SMS

### Auto-Enrollment Logic
Sau khi thanh toán thành công:
1. Tạo user sinh viên (mật khẩu = CMND) hoặc tìm theo CMND
2. Tìm lớp phù hợp (ngành, campus, hệ đào tạo, khóa)
3. Ghi danh vào lớp đầu tiên còn chỗ
4. Nếu hết chỗ → đưa vào `EDU_StudentPool`

### Hỗ trợ Thanh Toán Một Phần
```
balance = (newPayment + sumOfPreviousPayments) - bookingPrice
PaymentStatus = balance >= 0 ? Paid : PartPaid
```

### Discord Logging
Mọi lỗi webhook payment được gửi lên Discord với:
- Environment, app name, log level (Info/Warning/Error/Exception)
- Function name, transaction ID, client IP
- Request/response payloads (cắt 6000 chars)

---

## 9. CdnHub - Quản Lý File & Tài Liệu

**Đường dẫn:** `CdnHub/cdnhubmodule/`
**Solution:** `Presentation.CdnHubModule.Api.sln`

### Vai Trò
Module **quản lý file upload/download và chuyển đổi tài liệu sang PDF** để xem trên trình duyệt. Đây là module đơn giản nhất, chỉ có 1 controller chính.

### FileManagement Controller (`/FileManagement`)
| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/upload` | POST | Upload file (tối đa **1 GB**) |
| `/Download` | POST | Download file theo path |
| `/ViewFile` | GET | Xem file inline (DOCX → PDF qua Syncfusion) |
| `/PreView` | POST | Chuyển đổi file sang PDF (tối đa **100 MB**) |

### Chuyển Đổi Sang PDF

| Định dạng | Extension | Thư viện |
|-----------|-----------|----------|
| PDF | `.pdf` | Pass-through (không chuyển đổi) |
| Word | `.doc`, `.docx` | **Aspose.Words** → PDF |
| Excel | `.xls`, `.xlsx` | **Aspose.Cells** → PDF |
| PowerPoint | `.ppt`, `.pptx` | **Aspose.Slides** → PDF |
| HTML | `.html`, `.htm` | **PuppeteerSharp** (Chromium) → PDF |
| Text | `.txt` | Wrap HTML → PuppeteerSharp → PDF |
| Images | `.png`, `.jpg`, `.jpeg`, `.gif` | Base64 HTML img → PuppeteerSharp → PDF |

### Lưu Ý Quan Trọng
- **Không có authentication** - Ai cũng có thể upload/download
- **Không có database** - File lưu trực tiếp trên filesystem (`Resource/`)
- **Static file serving** - File upload có thể truy cập trực tiếp qua `/Resource/{path}`
- **Chromium auto-download** - PuppeteerSharp tự tải Chromium lần đầu chạy
- **Thương mại:** Aspose và Syncfusion là thư viện trả phí

---

## 10. CommonLibraries - Thư Viện Dùng Chung

**Đường dẫn:** `CommonLibraries/`

### GeneralCommon (`GeneralCommon`)
Thư viện utility thuần túy, không phụ thuộc ASP.NET Core.

#### `_String.cs` - Tiện ích chuỗi
| Method | Mô tả |
|--------|-------|
| `GetMD5Hash()` | Mã hóa MD5 |
| `Encrypt()` / `Decrypt()` | TripleDES (key: `systemKey@7037@#!`) |
| `NonUnicode()` | Chuyển tiếng Việt có dấu → không dấu |
| `RemoveTags()` | Xóa HTML tags |
| `FormatTemplate()` | Thay thế `{placeholder}` trong template |
| `Seri8Digit()` / `Seri5Digit()` | Sinh số serial ngẫu nhiên (không trùng 2 chữ số liên tiếp) |

#### `_Array.cs` - Tiện ích mảng
| Method | Mô tả |
|--------|-------|
| `ListStr2Str()` | Join list string bằng `,` (cho SQL IN clause) |
| `IntArr2String()` | Join mảng int |
| `Clone<T>()` | Deep clone list |

#### `_General.cs` - Tiện ích chung
| Method | Mô tả |
|--------|-------|
| `_GetFirtName()` | Lấy tên riêng từ họ tên đầy đủ (convention Việt Nam) |
| `_GetLastName()` | Lấy họ + tên đệm |
| `GenUniqueKeyUsingMethodNameAndArgs()` | Sinh cache key từ method name + args |

#### Enums & Constants
| Tên | Giá trị |
|-----|---------|
| `Status` | `Active = 1`, `InActive = -1` |
| `Gender` | `Female = 0`, `Male = 1` |
| `RoleEnum` | `SuperUser`, `Admin`, `User`, `Master` |
| `Config` | Page sizes, cache durations, list sizes |

### GeneralExtensions (`GeneralExtensions`)
Thư viện phụ thuộc ASP.NET Core.

#### `CacheMemoryManager` - Cache 2 tầng (Redis + In-Memory)
- Ưu tiên Redis, fallback sang MemoryCache khi Redis lỗi
- Tự động detect Redis availability lúc khởi tạo
- Methods: `Get<T>`, `Set<T>`, `Remove`, `GetOrSet<T>`

#### `SecurityContextAccessor` - Bảo mật HTTP context
- Trích xuất user identity, roles, permissions từ JWT claims
- Giải mã claim `Data` → `SecretModel`
- Lấy ngôn ngữ từ `Accept-Language` header (mặc định `vi`)

#### `EdotAuth` - Custom Authorization Attribute
- Mở rộng `AuthorizeAttribute`
- Kiểm tra claim/scope theo action (View, Create, Update)
- Hỗ trợ sub-permission qua `menufeatures` dictionary
- Trả về `UnauthorizedResult` nếu không có quyền

#### Zalo Notification
- `ZaloClient` - Gửi tin nhắn qua Zalo ZNS
- `ZaloNotificationService` - Service implementation
- `MessageSenderFactory` - Factory pattern cho notification services

#### `Encode.cs` - Mã hóa
- TripleDES encrypt/decrypt (key: `systemKey@7037@#!`)

### Cách Sử Dụng
Cả 2 thư viện được phân phối dưới dạng **DLL biên dịch sẵn**, reference qua `<HintPath>`:
```xml
<Reference Include="GeneralCommon">
  <HintPath>..\CommonLibrary\GeneralCommon.dll</HintPath>
</Reference>
<Reference Include="GeneralExtensions">
  <HintPath>..\CommonLibrary\GeneralExtensions.dll</HintPath>
</Reference>
```

---

## 11. Hướng Dẫn Cho Người Mới

### Bắt Đầu Từ Đâu?

Nếu bạn mới vào dự án, đây là lộ trình gợi ý:

#### Bước 1: Hiểu kiến trúc tổng thể
```
Client → Gateway → [Module] → Database
                 ↓
            CommonLibraries (dùng chung)
```

#### Bước 2: Chạy thử 1 module
```bash
# Ví dụ chạy StudentHub
cd StudentHub/studenthubmodule
dotnet restore "Presentation.StudentHubModule.Api.sln" --configfile nuget.config
dotnet build "Presentation.StudentHubModule.Api.sln"
cd Presentation.StudentHubModule.Api
dotnet run
# Mở browser: http://localhost:5xxx/swagger
```

#### Bước 3: Đọc code theo luồng
Bắt đầu từ `Program.cs` → Controllers → Services → Repository → DbContext

### Quy Ước Code Cần Nhớ

| Quy tắc | Ví dụ |
|---------|-------|
| Interface: tiền tố `I` | `IRepository<T>`, `IStudentService` |
| Private field: tiền tố `_` | `_repository`, `_unitOfWork` |
| Using đặt ngoài namespace | `using System;` rồi mới `namespace X {` |
| Soft delete: `Status = -1` | Không xóa cứng, chỉ đánh dấu Deleted |
| Audit fields tự động | `CreatedBy`, `CreatedAt`, `LastModifiedBy`, `LastModifiedAt` |
| Response chuẩn | `DataResponseModel<T>` với `Success`, `Error`, `Data` |
| Controller routing | `[HttpPost("[action]")]` → `/api/Controller/ActionName` |
| Auth attribute | `[EdotAuth]` hoặc `[EdotAuth([ActionEnum.View])]` |

### Cấu Trúc 1 Feature Mới

Khi thêm tính năng mới, làm theo thứ tự:

1. **Model/DTO** → `Presentation.Models/[Entity]/`
2. **Entity** → `Presentation.Context/CoreDBModelContext/`
3. **Migration** → `dotnet ef migrations add TenMigration`
4. **Repository Interface** → `Presentation.Repository/Interfaces/`
5. **Repository Implementation** → `Presentation.Repository/Repositories/`
6. **Service Interface** → `Presentation.Services/Interfaces/`
7. **Service Implementation** → `Presentation.Services/Services/`
8. **Controller** → `Presentation.[Module].Api/Controllers/`
9. **XML Comments** → Cho Swagger documentation
10. **Test** → `*.Tests` project (nếu có)

### Lệnh Test

```bash
# Chạy tất cả tests trong module
cd SystemManagement/systemmodule
dotnet test "Presentation.SystemManagement.API.sln"

# Chạy 1 file test
dotnet test --filter "FullyQualifiedName~CatAcademicCohortControllerTest"

# Chạy 1 method test
dotnet test --filter "FullyQualifiedName~CatAcademicCohortControllerTest.TestMethodName"

# Verbose output
dotnet test --logger "console;verbosity=detailed"
```

### Debug Tips

| Vấn đề | Giải pháp |
|--------|-----------|
| Không connect được database | Kiểm tra `appsettings.json` → `ConnectionStrings` |
| Redis lỗi | Kiểm tra `ConnectionStrings.Redis` trong appsettings |
| JWT không valid | Kiểm tra `Security:Tokens:Key` phải giống nhau giữa AuthenAPI và các module |
| Migration lỗi | `dotnet ef database update` hoặc xóa migration tạo lại |
| Swagger không hiện | Kiểm tra XML documentation file được generate (`<GenerateDocumentationFile>True</GenerateDocumentationFile>`) |

### Lưu Ý Quan Trọng

1. **CommonLibraries là DLL biên dịch sẵn** - Không sửa trực tiếp, phải build lại từ source riêng
2. **Mỗi module có solution riêng** - Build/test độc lập
3. **3 databases** - Master DB, Student DB, Identity DB - chú ý connection string
4. **Soft delete** - Luôn dùng `Status = GeneralEnum.Deleted`, không dùng `DELETE` SQL
5. **Audit tự động** - `EntityEDuXDBContext.SaveChanges()` tự điền `CreatedBy`, `CreatedAt`, v.v.
6. **Gateway routing** - Client gọi qua gateway, không gọi trực tiếp module
7. **CI/CD qua GitLab** - Push lên branch `beta` để deploy staging, `main` để deploy production
