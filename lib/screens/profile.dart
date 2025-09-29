import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import package baru
import '../theme_manager.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onHomeTap;
  const ProfilePage({super.key, this.onHomeTap});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 1. Perbarui struktur data untuk menyertakan username GitHub
  final List<Map<String, String>> teamMembers = [
    {
      'name': 'Muhammad Danial Irfani',
      'nim': '21120122130043',
      'githubUsername': 'IrDanial'
    },
    {
      'name': 'Izzat',
      'nim': '21120122130047',
      'githubUsername': 'izzat5233'
    },
    {
      'name': 'Arradhin Zidan',
      'nim': '21120122130047',
      'githubUsername': 'arradhin'
    }
    // Tambahkan anggota lain di sini
  ];

  // 2. Buat fungsi untuk membuka URL
  Future<void> _launchURL(String username) async {
    final Uri url = Uri.parse('https://github.com/$username');
    if (!await launchUrl(url)) {
      // Jika gagal, tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Team'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: widget.onHomeTap,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 3. Ubah UI untuk menampilkan daftar profil
          Text(
            'Team Members',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Gunakan map untuk mengubah setiap item di list menjadi Widget Card
          ...teamMembers.map((member) {
            final githubUsername = member['githubUsername']!;
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://avatars.githubusercontent.com/$githubUsername',
                  ),
                ),
                title: Text(
                  member['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(member['nim']!),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // Panggil fungsi untuk membuka profil GitHub saat di-tap
                  _launchURL(githubUsername);
                },
              ),
            );
          }).toList(),

          const Divider(height: 40),

          // Bagian untuk pengaturan (Settings)
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: themeManager.themeMode == ThemeMode.dark,
            onChanged: (newValue) {
              themeManager.toggleTheme(newValue);
            },
          ),
        ],
      ),
    );
  }
}