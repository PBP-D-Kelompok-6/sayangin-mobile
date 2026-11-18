import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'marketplace/screens/catalog_page.dart';
import 'marketplace/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Satu CookieRequest untuk semua modul, supaya session login dipakai bersama
    return Provider(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'Sayangin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: MarketColors.maroon, surface: MarketColors.paper),
          scaffoldBackgroundColor: MarketColors.paper,
        ),
        // Sementara langsung ke Marketplace; nanti diganti halaman utama/navigasi kelompok
        home: const CatalogPage(),
      ),
    );
  }
}
