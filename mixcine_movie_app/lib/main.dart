import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//import 'package:firebase_core/firebase_core.dart'; // Hàng mới của bro
import 'package:shared_preferences/shared_preferences.dart'; // Hàng chống cháy màn hình đỏ hồi sáng

// Import provider chứa cấu hình SharedPreferences (Nhớ check lại đường dẫn nếu cần)
import 'package:mixcine_movie_app/presentation/providers/subscription_provider.dart';

import 'app.dart';

// Đã đổi thành async để chờ các dịch vụ load xong
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize sqflite for Desktop (Windows/macOS/Linux)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Khởi tạo Firebase (Tạm comment lại, chừng nào bro setup xong Firebase qua CLI thì mở ra)
  // await Firebase.initializeApp();

  // 3. Khởi tạo SharedPreferences (BẮT BUỘC PHẢI CÓ ĐỂ KHÔNG BỊ MÀN HÌNH ĐỎ)
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MixcineApp(),
    ),
  );
}