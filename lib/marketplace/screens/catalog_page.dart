// Katalog barang preloved: cari, filter kategori, lalu buka detail
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../marketplace_api.dart';
import '../models.dart';
import '../widgets.dart';
import 'cart_page.dart';
import 'orders_page.dart';
import 'product_detail_page.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final MarketplaceApi _api;
  late Future<Catalog> _catalog;
  String _query = '';
  String _category = '';
  List<Choice> _categories = []; // disimpan supaya chip tidak hilang saat memuat ulang

  @override
  void initState() {
    super.initState();
    _api = MarketplaceApi(context.read<CookieRequest>());
    _catalog = _load();
  }

  Future<Catalog> _load() async {
    final catalog = await _api.catalog(q: _query, category: _category);
    if (mounted) setState(() => _categories = catalog.categories);
    return catalog;
  }

  void _reload() => setState(() => _catalog = _load());

  void _open(Widget page) => Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            tooltip: 'Pesananku',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => _open(const OrdersPage()),
          ),
          IconButton(
            tooltip: 'Keranjang',
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => _open(const CartPage()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Cari blazer, tas, sepatu…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (value) {
                _query = value.trim();
                _reload();
              },
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final choice in [Choice.all, ..._categories])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(choice.label),
                      selected: _category == choice.value,
                      onSelected: (_) {
                        _category = choice.value;
                        _reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AsyncView<Catalog>(
              future: _catalog,
              onRetry: _reload,
              builder: (catalog) {
                if (catalog.products.isEmpty) {
                  return const Center(child: Text('Belum ada barang yang cocok.'));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _reload();
                    await _catalog;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.66,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: catalog.products.length,
                    itemBuilder: (_, i) {
                      final product = catalog.products[i];
                      return ProductCard(
                        product: product,
                        onTap: () => _open(ProductDetailPage(productId: product.id)),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
