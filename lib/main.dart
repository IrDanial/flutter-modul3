import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Pastikan ini di-import
import 'widget/navigation.dart';
import 'theme_manager.dart';

// Buat instance ThemeManager
ThemeManager _themeManager = ThemeManager();

void main() {
  runApp(const CountryApp());
}

class CountryApp extends StatelessWidget {
  const CountryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider HARUS berada di atas MaterialApp.
    return ChangeNotifierProvider(
      create: (_) => _themeManager,
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          // MaterialApp berada di dalam Consumer/Provider
          return MaterialApp(
            title: 'ApiCountries Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.indigo,
              brightness: Brightness.dark,
            ),
            themeMode: themeManager.themeMode,
            home: const NavigationPage(),
          );
        },
      ),
    );
  }
}