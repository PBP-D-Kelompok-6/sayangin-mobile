import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'impact/screens/impact_dashboard_page.dart';
import 'impact/widgets.dart';

// SEMENTARA: aplikasi langsung membuka Modul Dampak sampai kerangka & navigasi kelompok masuk ke main.
// Yang perlu dipertahankan saat digabung: Provider<CookieRequest> di atas MaterialApp.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CookieRequest(), // satu sesi login untuk seluruh aplikasi
      child: MaterialApp(
        title: 'Sayangin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: ImpactColors.maroon, surface: ImpactColors.paper),
          scaffoldBackgroundColor: ImpactColors.paper,
        ),
        home: const ImpactDashboardPage(),
      ),
    );
  }
}
