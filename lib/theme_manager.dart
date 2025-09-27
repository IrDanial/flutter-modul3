// lib/theme_manager.dart

import 'package:flutter/material.dart';

// Class ini menggunakan ValueNotifier untuk memberitahu aplikasi
// saat tema berubah.
class ThemeManager with ChangeNotifier {
  // Secara default, tema dimulai dari mode terang (light).
  ThemeMode _themeMode = ThemeMode.light;

  // Getter untuk mendapatkan themeMode saat ini.
  get themeMode => _themeMode;

  // Fungsi untuk mengubah tema.
  toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    // Beri tahu semua listener (widget) bahwa ada perubahan.
    notifyListeners();
  }
}