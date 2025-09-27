import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    futureCountries = fetchCountries();
    // Setelah data didapat, simpan ke dalam list
    futureCountries.then((countries) {
      setState(() {
        allCountries = countries;
        filteredCountries = allCountries;
      });
    });

    // Listener untuk memanggil fungsi filter setiap ada perubahan teks
    searchController.addListener(() {
      filterCountries();
    });
  }

  // Hapus listener saat widget dihancurkan untuk mencegah memory leak
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterCountries() {
    List<Country> results = [];
    if (searchController.text.isEmpty) {
      // Jika search bar kosong, tampilkan semua negara
      results = allCountries;
    } else {
      // Jika tidak, filter berdasarkan nama
      results = allCountries
          .where((country) => country.name
              .toLowerCase()
              .contains(searchController.text.toLowerCase()))
          .toList();
    }

    // Update state untuk me-render ulang UI dengan daftar yang sudah difilter
    setState(() {
      filteredCountries = results;
    });
  }

  Future<List<Country>> fetchCountries() async {
    // ... (Fungsi fetchCountries tetap sama)
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
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Search for a country...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
            const SizedBox(height: 10), // Memberi sedikit spasi
            // List of Countries
            Expanded(
              child: FutureBuilder<List<Country>>(
                future: futureCountries,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (allCountries.isEmpty) {
                    return const Center(child: Text('No countries found'));
                  }

                  // Gunakan filteredCountries untuk membangun ListView
                  return ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, i) {
                      final country = filteredCountries[i];
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
            ),
          ],
        ),
      ),
    );
  }
}

// Class Country tetap sama, tidak perlu diubah
class Country {
  // ...
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
      langs = (json['languages'] as List)
          .map((l) => l['name'].toString())
          .toList();
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