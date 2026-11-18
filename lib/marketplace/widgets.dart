// Widget kecil yang dipakai bersama oleh halaman-halaman Modul Marketplace
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models.dart';

// Warna mengikuti static/css/tokens.css di web (sama dengan Modul Dampak)
class MarketColors {
  static const ink = Color(0xFF1A1210);
  static const inkMuted = Color(0xFF6E625E);
  static const maroon = Color(0xFF6B1420);
  static const paper = Color(0xFFFAFAF8);
  static const grey100 = Color(0xFFF1F1EF);
}

final _rupiah = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

String rupiah(int value) => _rupiah.format(value);

// Tampilan FutureBuilder yang seragam: loading, error + tombol coba lagi, lalu isi
class AsyncView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;

  const AsyncView({super.key, required this.future, required this.builder, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
                ],
              ),
            ),
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}

class ProductPhoto extends StatelessWidget {
  final String url;
  final double? size;

  const ProductPhoto(this.url, {super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: MarketColors.grey100,
        child: const Icon(Icons.image_not_supported_outlined, color: MarketColors.inkMuted),
      ),
    );
  }
}

// Kartu barang di katalog: foto, nama, harga, kondisi, kota
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(color: MarketColors.inkMuted);
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SizedBox(width: double.infinity, child: ProductPhoto(product.photo))),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(product.priceLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text('${product.conditionLabel} · ${product.city}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: muted),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
