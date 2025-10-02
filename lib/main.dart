import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Impor package provider
import 'widget/navigation.dart';
import 'theme_manager.dart'; // Impor file theme manager

// Buat instance dari ThemeManager yang bisa diakses di seluruh aplikasi
ThemeManager _themeManager = ThemeManager();

void main() {
  runApp(const CountryApp());
}

class CountryApp extends StatelessWidget {
  const CountryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan ChangeNotifierProvider untuk menyediakan ThemeManager ke widget di bawahnya
    return ChangeNotifierProvider(
      create: (_) => _themeManager,
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return MaterialApp(
            title: 'ApiCountries Demo',
            debugShowCheckedModeBanner: false,
            // Tema untuk mode terang
            theme: ThemeData(
              primarySwatch: Colors.blue,
              brightness: Brightness.light,
            ),
            // Tema untuk mode gelap
            darkTheme: ThemeData(
              primarySwatch: Colors.indigo, // Warna yang berbeda untuk dark mode
              brightness: Brightness.dark,
              // Anda bisa kustomisasi lebih banyak di sini
            ),
            // Atur mode tema berdasarkan state dari ThemeManager
            themeMode: themeManager.themeMode,
            home: const NavigationPage(),
          );
        },
      ),
    );
  }
}