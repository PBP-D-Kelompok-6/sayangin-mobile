import 'package:flutter_test/flutter_test.dart';
import 'package:sayangin_mobile/marketplace/models.dart';

// Memastikan JSON dari /marketplace/api/... (marketplace/api.py di repo web) bisa dibaca model Marketplace.
const productJson = {
  'id': 1, 'name': 'Blazer wol abu', 'price': 185000, 'price_label': 'Rp185.000', 'category': 'atasan',
  'category_label': 'Atasan', 'condition': 'terawat', 'condition_label': 'Terawat', 'size': 'M',
  'city': 'Jakarta', 'seller': 'nadia', 'photo': 'http://x/static/blazer.jpg',
};

void main() {
  test('Catalog.fromJson: daftar barang dan pilihan kategori', () {
    final catalog = Catalog.fromJson({
      'count': 1,
      'results': [productJson],
      'categories': [{'value': 'atasan', 'label': 'Atasan'}],
      'conditions': [],
    });
    expect(catalog.products.single.priceLabel, 'Rp185.000');
    expect(catalog.products.single.photos, ['http://x/static/blazer.jpg']); // daftar tanpa galeri: foto utama
    expect(catalog.categories.single.label, 'Atasan');
  });

  test('Product.fromJson: detail barang', () {
    final product = Product.fromJson({
      ...productJson, 'description': 'Wol', 'condition_note': '', 'used_duration': '2 tahun',
      'weight_grams': 500, 'photos': ['a', 'b'], 'in_cart': true,
    });
    expect(product.photos, ['a', 'b']);
    expect(product.inCart, isTrue);
  });

  test('Cart.fromJson: dikelompokkan per penjual', () {
    final cart = Cart.fromJson({
      'count': 1, 'subtotal': 185000, 'subtotal_label': 'Rp185.000',
      'groups': [{'seller': 'nadia', 'items': [productJson]}],
    });
    expect(cart.groups.single.seller, 'nadia');
    expect(cart.groups.single.items.single.id, 1);
  });

  test('Order.fromJson: daftar dan detail pesanan', () {
    final order = Order.fromJson({
      'id': 1, 'code': 'SYG-00001', 'status': 'dibayar', 'status_label': 'Pembayaran diterima',
      'seller': 'nadia', 'buyer': 'ira', 'courier_label': 'Reguler · 2–4 hari', 'payment_label': 'Transfer bank',
      'subtotal': 185000, 'shipping_cost': 15000, 'total': 200000, 'created_at': '2026-11-18T03:00:00Z',
      'items': [{'product_id': 1, 'name': 'Blazer wol abu', 'price': 185000, 'photo': 'http://x/a.jpg'}],
      'recipient': 'Ira', 'address': 'Jl. Margonda', 'city': 'Depok', 'tracking_number': '', 'eta': '20–22 Nov',
      'steps': [{'label': 'Pembayaran diterima', 'meta': '18 Nov, 10.00', 'done': true, 'now': false}],
    });
    expect(order.total, 200000);
    expect(order.steps.single.done, isTrue);
    expect(order.items.single.name, 'Blazer wol abu');
  });
}
