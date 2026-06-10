import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier quản lý việc chuyển đổi giữa Dark và Light mode
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark; // Mặc định là Dark mode như yêu cầu của app

  // Hàm đảo ngược trạng thái Theme
  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}

// Provider để các widget khác có thể lắng nghe và thay đổi Theme
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
