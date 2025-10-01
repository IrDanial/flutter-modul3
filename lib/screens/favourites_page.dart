import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'detail.dart';
import 'home.dart'; // Kita butuh class Country dari sini

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Country>> _favoriteCountriesFuture;

  @override
  void initState() {
    super.initState();
    _favoriteCountriesFuture = _getFavoriteCountries();
  }

  // Fungsi untuk mengambil semua negara dari API, lalu memfilternya
  Future<List<Country>> _getFavoriteCountries() async {
    // 1. Ambil daftar nama negara favorit dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final favoriteNames = prefs.getStringList('favoriteCountries') ?? [];

    if (favoriteNames.isEmpty) {
      return []; // Kembalikan list kosong jika tidak ada favorit
    }

    // 2. Ambil semua data negara dari API (sama seperti di HomePage)
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List<dynamic> allCountriesJson = jsonDecode(respBody);
      final allCountries = allCountriesJson.map((j) => Country.fromJson(j)).toList();

      // 3. Filter daftar semua negara berdasarkan nama yang ada di favorit
      return allCountries.where((country) => favoriteNames.contains(country.name)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Countries'),
      ),
      body: FutureBuilder<List<Country>>(
        future: _favoriteCountriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite countries yet.'));
          }

          final favorites = snapshot.data!;
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, i) {
              final country = favorites[i];
              return Card(
                child: ListTile(
                  leading: country.flagsPng != null
                      ? Image.network(country.flagsPng!, width: 50)
                      : const SizedBox(width: 50),
                  title: Text(country.name),
                  subtitle: Text(country.region),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(country: country),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}