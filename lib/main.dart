// lib/main.dart (TEMPORARY TESTING)
import 'package:flutter/material.dart';
import 'package:sayangin_mobile/donation/screens/donation_page.dart';

// SEMENTARA: aplikasi langsung membuka Modul Dampak sampai kerangka & navigasi kelompok masuk ke main.
// Yang perlu dipertahankan saat digabung: Provider<CookieRequest> di atas MaterialApp.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sayangin Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal, // Sesuaikan dengan warna brand kelompok
        ),
        useMaterial3: true,
      ),
      // Menjalankan halaman donasi langsung sebagai halaman awal untuk testing
      home: const DonationPage(),
    );
  }
}