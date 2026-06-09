import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDatabase();

    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'movie_app.db');

    return await openDatabase(
      path,
      version: 3, // ✓ Đã nâng lên version 3 với cấu trúc schema chuẩn hóa

      onCreate: (db, version) async {
        // 1. Tạo bảng favorites (Danh sách yêu thích)
        await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          movie_id INTEGER NOT NULL,
          UNIQUE(user_id, movie_id)
        )
        ''');

        // 2. Tạo bảng watch_history (Lịch sử xem phim - Hỗ trợ đa người dùng & thời gian xem gần nhất)
        await db.execute('''
        CREATE TABLE watch_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          movie_id INTEGER NOT NULL,
          progress INTEGER NOT NULL,
          updated_at TEXT NOT NULL, -- Lưu thời gian dưới dạng chuỗi ISO8601 để sắp xếp phim mới xem lên đầu
          UNIQUE(user_id, movie_id) -- Đảm bảo mỗi user chỉ có một tiến độ duy nhất cho một bộ phim
        )
        ''');

        // 3. Tạo bảng reviews (Đánh giá/Bình luận phim - Đầy đủ thông tin định danh tác giả và thời gian tạo)
        await db.execute('''
        CREATE TABLE reviews(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          movie_id INTEGER NOT NULL,
          user_id TEXT NOT NULL,
          author_name TEXT NOT NULL, -- Tên hiển thị của người dùng để tối ưu hiển thị không cần join bảng
          comment TEXT NOT NULL,
          rating REAL NOT NULL,
          created_at TEXT NOT NULL -- Lưu thời gian tạo bình luận dưới dạng chuỗi ISO8601
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Migration từ version 1 lên 2: Cập nhật bảng favorites thêm cột user_id
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS favorites');
          await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            movie_id INTEGER NOT NULL,
            UNIQUE(user_id, movie_id)
          )
          ''');
        }

        // Migration từ version 2 lên 3: Thêm các bảng mới đã qua rà soát mà không làm mất dữ liệu cũ
        if (oldVersion < 3) {
          await db.execute('''
          CREATE TABLE IF NOT EXISTS watch_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            movie_id INTEGER NOT NULL,
            progress INTEGER NOT NULL,
            updated_at TEXT NOT NULL,
            UNIQUE(user_id, movie_id)
          )
          ''');

          await db.execute('''
          CREATE TABLE IF NOT EXISTS reviews(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            movie_id INTEGER NOT NULL,
            user_id TEXT NOT NULL,
            author_name TEXT NOT NULL,
            comment TEXT NOT NULL,
            rating REAL NOT NULL,
            created_at TEXT NOT NULL
          )
          ''');
        }
      },
    );
  }
}
