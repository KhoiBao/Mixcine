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
      version: 5, // Nâng lên version 5 để thêm cột phone_number vào bảng users

      onCreate: (db, version) async {
        // 1. Tạo bảng users
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          full_name TEXT,
          phone_number TEXT,
          plan TEXT DEFAULT 'free'
        )
        ''');

        // 2. Tạo bảng favorites
        await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          movie_id INTEGER NOT NULL,
          UNIQUE(user_id, movie_id)
        )
        ''');

        // 3. Tạo bảng watch_history
        await db.execute('''
        CREATE TABLE watch_history(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          movie_id INTEGER NOT NULL,
          progress INTEGER NOT NULL,
          updated_at TEXT NOT NULL,
          UNIQUE(user_id, movie_id)
        )
        ''');

        // 4. Tạo bảng reviews
        await db.execute('''
        CREATE TABLE reviews(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          movie_id INTEGER NOT NULL,
          user_id TEXT NOT NULL,
          author_name TEXT NOT NULL,
          comment TEXT NOT NULL,
          rating REAL NOT NULL,
          created_at TEXT NOT NULL
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          // Cách đơn giản nhất để cập nhật schema khi đang dev là xóa bảng tạo lại hoặc thêm cột
          // Ở đây tôi thêm cột phone_number nếu chưa có
          try {
            await db.execute('ALTER TABLE users ADD COLUMN phone_number TEXT');
          } catch (e) {
            // Bảng có thể chưa tồn tại hoặc cột đã có
          }
        }
      },
    );
  }
}
