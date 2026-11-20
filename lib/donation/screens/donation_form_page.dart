import 'package:flutter/material.dart';

class DonationFormPage extends StatelessWidget {
  const DonationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Formulir Donasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Halaman Form Donasi (Placeholder)'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Kembali ke halaman utama Donasi
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Donasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}