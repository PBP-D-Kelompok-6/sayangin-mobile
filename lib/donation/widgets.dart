import 'package:flutter/material.dart';
import 'package:sayangin_mobile/donation/screens/donation_page.dart';

class DonationDrawer extends StatelessWidget {
  const DonationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Sayangin Mobile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          // Navigasi ke Halaman Utama 
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text("Menu Utama"),
          ),
          // Navigasi ke Halaman Utama Donasi
          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text('Daftar Donasi'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationPage(),
                ),
              );
            },
          ),
          // Placeholder untuk modul anggota lain (Impact, Marketplace, dll.)
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Modul Lain (Placeholder)'),
          ),
        ],
      ),
    );
  }
}