import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thêm import này

// Import cái provider của bro vào đây (nhớ trỏ đúng đường dẫn thư mục nhé)
import 'package:mixcine_movie_app/presentation/providers/subscription_provider.dart';

import 'app.dart';

// 1. Đổi main() thành main() async
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for Desktop (Windows/macOS/Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Khởi tạo SharedPreferences và đợi nó load xong
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
      ProviderScope(
        // 3. Ghi đè provider rỗng bằng instance thật vừa tạo
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const MixcineApp(),
      )
  );
}