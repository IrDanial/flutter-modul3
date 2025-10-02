import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widget/navigation.dart';
import 'theme_manager.dart';

ThemeManager _themeManager = ThemeManager();

void main() {
  runApp(const CountryApp());
}

class CountryApp extends StatelessWidget {
  const CountryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _themeManager,
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
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