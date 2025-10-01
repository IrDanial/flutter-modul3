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
  late Future<List<Country>> futureCountries;
  List<Country> allCountries = [];
  List<Country> filteredCountries = [];
  final TextEditingController searchController = TextEditingController();
  final Set<String> _favorites = <String>{};

  @override
  void initState() {
    super.initState();
    futureCountries = fetchCountries();
    _loadFavorites();
    futureCountries.then((countries) {
      setState(() {
        allCountries = countries;
        filteredCountries = allCountries;
      });
    });
    searchController.addListener(() {
      filterCountries();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
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
      prefs.setStringList('favoriteCountries', _favorites.toList());
    });
  }

  void filterCountries() {
    List<Country> results = [];
    if (searchController.text.isEmpty) {
      results = allCountries;
    } else {
      results = allCountries
          .where((country) => country.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }
    setState(() {
      filteredCountries = results;
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
      appBar: AppBar(
        title: const Text('Countries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search for a country...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Country>>(
                future: futureCountries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (allCountries.isEmpty) {
                    return Center(
                        child: Text(searchController.text.isNotEmpty
                            ? 'No countries found'
                            : 'Loading countries...'));
                  }

                  return ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, i) {
                      final country = filteredCountries[i];
                      final isFavorite = _favorites.contains(country.name);
                      return Card(
                        child: ListTile(
                          leading: country.flagsPng != null
                              ? Image.network(country.flagsPng!, width: 50)
                              : const SizedBox(width: 50),
                          title: Text(country.name),
                          subtitle: Text(country.region),
                          trailing: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () => _toggleFavorite(country.name),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(country: country),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    List<String>? langs;
    if (json['languages'] != null) {
      langs =
          (json['languages'] as List).map((l) => l['name'].toString()).toList();
    }
    List<String>? cur;
    if (json['currencies'] != null) {
      cur = (json['currencies'] as List)
          .map((c) => c['name'].toString())
          .toList();
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