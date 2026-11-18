// Pemanggilan API Modul Marketplace (marketplace/api.py di repo web)
// Login memakai session cookie dari CookieRequest (pbp_django_auth), sama untuk semua modul
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'models.dart';

// Alamat situs Django; bisa diganti saat run, mis.
// flutter run --dart-define=BASE_URL=http://10.0.2.2:8000
const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'https://muhammad-ghazi51-sayang-in.pws.cs.ui.ac.id',
);

// Error dari API, mis. belum login (403) atau barang sudah terjual (404)
class MarketplaceApiException implements Exception {
  final String message;

  MarketplaceApiException(this.message);

  @override
  String toString() => message;
}

class MarketplaceApi {
  final CookieRequest request;

  MarketplaceApi(this.request);

  // q = kata kunci, category = "" untuk semua kategori (filter sama dengan web)
  Future<Catalog> catalog({String q = '', String category = ''}) async {
    final query = Uri(queryParameters: {'q': q, 'kategori': category}).query;
    return Catalog.fromJson(_check(await request.get('$baseUrl/marketplace/api/katalog/?$query')));
  }

  Future<Product> product(int id) async {
    return Product.fromJson(_check(await request.get('$baseUrl/marketplace/api/katalog/$id/')));
  }

  Future<Cart> cart() async {
    return Cart.fromJson(_check(await request.get('$baseUrl/marketplace/api/keranjang/')));
  }

  Future<Cart> addToCart(int productId) async {
    return Cart.fromJson(_check(await request.post('$baseUrl/marketplace/api/keranjang/', {'product': '$productId'})));
  }

  // CookieRequest tidak punya delete, jadi dikirim lewat http dengan cookie session yang sama
  Future<Cart> removeFromCart(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/marketplace/api/keranjang/$productId/'),
      headers: request.headers,
    );
    return Cart.fromJson(_check(jsonDecode(utf8.decode(response.bodyBytes))));
  }

  Future<List<Order>> orders() async {
    final json = _check(await request.get('$baseUrl/marketplace/api/pesanan/'));
    return [for (final row in json) Order.fromJson(row)];
  }

  Future<Order> order(int id) async {
    return Order.fromJson(_check(await request.get('$baseUrl/marketplace/api/pesanan/$id/')));
  }

  // DRF mengirim {"detail": "..."} untuk 400/403/404
  dynamic _check(dynamic json) {
    if (json is Map && json.containsKey('detail')) {
      final detail = json['detail'].toString();
      // 403 bawaan DRF berbahasa Inggris; diganti supaya jelas bagi pengguna
      throw MarketplaceApiException(
          detail.startsWith('Authentication credentials') ? 'Masuk dulu untuk melihat halaman ini.' : detail);
    }
    return json;
  }
}
