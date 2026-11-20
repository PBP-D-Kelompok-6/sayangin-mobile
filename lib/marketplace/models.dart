// Model Dart untuk JSON dari /marketplace/api/... (marketplace/api.py di repo web)

class Product {
  final int id;
  final String name;
  final int price;
  final String priceLabel; // "Rp185.000", diformat server supaya sama dengan web
  final String category;
  final String categoryLabel;
  final String conditionLabel;
  final String size;
  final String city;
  final String seller;
  final String photo;

  // Hanya ada di detail barang (/api/katalog/<id>/)
  final String description;
  final String conditionNote;
  final String usedDuration;
  final List<String> photos;
  final bool inCart;

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        price = json['price'],
        priceLabel = json['price_label'],
        category = json['category'],
        categoryLabel = json['category_label'],
        conditionLabel = json['condition_label'],
        size = json['size'] ?? '',
        city = json['city'],
        seller = json['seller'],
        photo = json['photo'],
        description = json['description'] ?? '',
        conditionNote = json['condition_note'] ?? '',
        usedDuration = json['used_duration'] ?? '',
        photos = [for (final p in json['photos'] ?? [json['photo']]) p as String],
        inCart = json['in_cart'] ?? false;
}

// Pilihan filter (kategori / kondisi) dari server, supaya sama dengan web
class Choice {
  final String value;
  final String label;

  const Choice(this.value, this.label);

  static const all = Choice('', 'Semua'); // value kosong = tanpa filter

  Choice.fromJson(Map<String, dynamic> json)
      : value = json['value'],
        label = json['label'];
}

class Catalog {
  final List<Product> products;
  final List<Choice> categories;

  Catalog.fromJson(Map<String, dynamic> json)
      : products = [for (final p in json['results']) Product.fromJson(p)],
        categories = [for (final c in json['categories']) Choice.fromJson(c)];
}

// Keranjang dikelompokkan per penjual, karena satu pesanan = satu penjual
class CartGroup {
  final String seller;
  final List<Product> items;

  CartGroup.fromJson(Map<String, dynamic> json)
      : seller = json['seller'],
        items = [for (final p in json['items']) Product.fromJson(p)];
}

class Cart {
  final int count;
  final String subtotalLabel;
  final List<CartGroup> groups;

  Cart.fromJson(Map<String, dynamic> json)
      : count = json['count'],
        subtotalLabel = json['subtotal_label'],
        groups = [for (final g in json['groups']) CartGroup.fromJson(g)];
}

class OrderItem {
  final String name;
  final int price;
  final String photo;

  OrderItem.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        price = json['price'],
        photo = json['photo'];
}

// Satu langkah pelacakan: Dibayar -> Dikemas -> Dikirim -> Tiba -> Selesai
class OrderStep {
  final String label;
  final String meta;
  final bool done;
  final bool now;

  OrderStep.fromJson(Map<String, dynamic> json)
      : label = json['label'],
        meta = json['meta'],
        done = json['done'],
        now = json['now'];
}

class Order {
  final int id;
  final String code; // "SYG-00001"
  final String status;
  final String statusLabel;
  final String seller;
  final String courierLabel;
  final String paymentLabel;
  final int subtotal;
  final int shippingCost;
  final int total;
  final DateTime createdAt;
  final List<OrderItem> items;

  // Hanya ada di detail pesanan (/api/pesanan/<id>/)
  final String recipient;
  final String address;
  final String city;
  final String trackingNumber;
  final List<OrderStep> steps;

  Order.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        code = json['code'],
        status = json['status'],
        statusLabel = json['status_label'],
        seller = json['seller'],
        courierLabel = json['courier_label'],
        paymentLabel = json['payment_label'],
        subtotal = json['subtotal'],
        shippingCost = json['shipping_cost'],
        total = json['total'],
        createdAt = DateTime.parse(json['created_at']).toLocal(),
        items = [for (final i in json['items']) OrderItem.fromJson(i)],
        recipient = json['recipient'] ?? '',
        address = json['address'] ?? '',
        city = json['city'] ?? '',
        trackingNumber = json['tracking_number'] ?? '',
        steps = [for (final s in json['steps'] ?? []) OrderStep.fromJson(s)];
}
