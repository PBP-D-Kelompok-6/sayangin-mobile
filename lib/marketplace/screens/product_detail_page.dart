// Detail satu barang: galeri foto, info kondisi, dan tombol masuk keranjang
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../marketplace_api.dart';
import '../models.dart';
import '../widgets.dart';
import 'cart_page.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final MarketplaceApi _api;
  late Future<Product> _product;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _api = MarketplaceApi(context.read<CookieRequest>());
    _product = _api.product(widget.productId);
  }

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _api.addToCart(widget.productId);
      messenger.showSnackBar(SnackBar(
        content: const Text('Masuk keranjang.'),
        action: SnackBarAction(
          label: 'Lihat',
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
        ),
      ));
      setState(() => _product = _api.product(widget.productId)); // tombol jadi "Sudah di keranjang"
    } on MarketplaceApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail barang')),
      body: AsyncView<Product>(
        future: _product,
        onRetry: () => setState(() => _product = _api.product(widget.productId)),
        builder: (product) {
          final text = Theme.of(context).textTheme;
          final facts = {
            'Kategori': product.categoryLabel,
            'Kondisi': product.conditionLabel,
            if (product.size.isNotEmpty) 'Ukuran': product.size,
            if (product.usedDuration.isNotEmpty) 'Lama dipakai': product.usedDuration,
            'Lokasi': product.city,
            'Penjual': '@${product.seller}',
          };
          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: PageView(children: [for (final url in product.photos) ProductPhoto(url)]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: text.titleLarge),
                          const SizedBox(height: 4),
                          Text(product.priceLabel,
                              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          for (final fact in facts.entries)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: Text(fact.key, style: const TextStyle(color: MarketColors.inkMuted)),
                                  ),
                                  Expanded(child: Text(fact.value)),
                                ],
                              ),
                            ),
                          if (product.conditionNote.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text('Catatan kondisi: ${product.conditionNote}'),
                          ],
                          if (product.description.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(product.description),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: product.inCart || _adding ? null : _addToCart,
                      child: Text(product.inCart ? 'Sudah di keranjang' : 'Tambah ke keranjang'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
