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
      version: 2, // ✓ Increased from 1 to 2

      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE favorites(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id TEXT NOT NULL,
          movie_id INTEGER NOT NULL,
          UNIQUE(user_id, movie_id)
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // ✓ Migration: Add user_id column and recreate table
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
      },
    );
  }
}
