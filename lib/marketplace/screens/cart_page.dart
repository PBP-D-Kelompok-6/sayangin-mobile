// Keranjang: barang dikelompokkan per penjual, bisa dihapus satu per satu
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../marketplace_api.dart';
import '../models.dart';
import '../widgets.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late final MarketplaceApi _api;
  late Future<Cart> _cart;

  @override
  void initState() {
    super.initState();
    _api = MarketplaceApi(context.read<CookieRequest>());
    _cart = _api.cart();
  }

  Future<void> _remove(Product product) async {
    try {
      final cart = await _api.removeFromCart(product.id);
      setState(() => _cart = Future.value(cart));
    } on MarketplaceApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: AsyncView<Cart>(
        future: _cart,
        onRetry: () => setState(() => _cart = _api.cart()),
        builder: (cart) {
          if (cart.groups.isEmpty) {
            return const Center(child: Text('Keranjangmu masih kosong.'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final group in cart.groups) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Text('Dari @${group.seller}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      for (final product in group.items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ProductPhoto(product.photo, size: 56),
                          ),
                          title: Text(product.name),
                          subtitle: Text('${product.priceLabel} · ${product.conditionLabel}'),
                          trailing: IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _remove(product),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Text('${cart.count} barang')),
                      Text('Subtotal ${cart.subtotalLabel}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
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
