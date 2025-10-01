import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Country>> countries;
  // Gunakan Set untuk efisiensi pengecekan favorit
  final Set<String> _favorites = <String>{};

  @override
  void initState() {
    super.initState();
    countries = fetchCountries();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Ambil daftar favorit, jika tidak ada, gunakan list kosong
      final favoriteNames = prefs.getStringList('favoriteCountries') ?? [];
      _favorites.addAll(favoriteNames);
    });
  }

  Future<void> _toggleFavorite(String countryName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(countryName)) {
        _favorites.remove(countryName);
      } else {
        _favorites.add(countryName);
      }
      // Simpan kembali ke SharedPreferences
      prefs.setStringList('favoriteCountries', _favorites.toList());
    });
  }
  
  Future<List<Country>> fetchCountries() async {
    final uri = Uri.parse('https://www.apicountries.com/countries');
    final request = await HttpClient().getUrl(uri);
    final response = await request.close();

    if (response.statusCode == 200) {
      final respBody = await response.transform(utf8.decoder).join();
      final List<dynamic> jsonData = jsonDecode(respBody);
      return jsonData.map((j) => Country.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countries')),
      body: FutureBuilder<List<Country>>(
        future: countries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No countries found'));
          }
          final list = snapshot.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final country = list[i];
              final isFavorite = _favorites.contains(country.name);
              return Card(
                child: ListTile(
                  leading: country.flagsPng != null
                      ? Image.network(country.flagsPng!, width: 50)
                      : const SizedBox(width: 50),
                  title: Text(country.name),
                  subtitle: Text(country.region),
                  // Tombol favorit di sebelah kanan
                  trailing: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => _toggleFavorite(country.name),
                  ),
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

// Class Country tidak berubah
class Country {
  final String name;
  final String region;
  final String? capital;
  final int population;
  final String? flagsPng;
  final List<String>? languages;
  final List<String>? currencies;

  Country({
    required this.name,
    required this.region,
    required this.population,
    this.capital,
    this.flagsPng,
    this.languages,
    this.currencies,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    // ... (kode factory tidak berubah)
    List<String>? langs;
    if (json['languages'] != null) {
      langs = (json['languages'] as List).map((l) => l['name'].toString()).toList();
    }
    List<String>? cur;
    if (json['currencies'] != null) {
      cur = (json['currencies'] as List).map((c) => c['name'].toString()).toList();
    }
    return Country(
      name: json['name'] ?? 'N/A',
      region: json['region'] ?? 'N/A',
      population: json['population'] ?? 0,
      capital: json['capital'],
      flagsPng: json['flags'] != null ? json['flags']['png'] : null,
      languages: langs,
      currencies: cur,
    );
  }
}