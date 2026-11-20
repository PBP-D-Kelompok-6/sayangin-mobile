// Riwayat pembelian dan pelacakan satu pesanan
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../marketplace_api.dart';
import '../models.dart';
import '../widgets.dart';

final _date = DateFormat('d/M/yyyy');

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late final MarketplaceApi _api;
  late Future<List<Order>> _orders;

  @override
  void initState() {
    super.initState();
    _api = MarketplaceApi(context.read<CookieRequest>());
    _orders = _api.orders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesananku')),
      body: AsyncView<List<Order>>(
        future: _orders,
        onRetry: () => setState(() => _orders = _api.orders()),
        builder: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('Belum ada pesanan.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (_, i) {
              final order = orders[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductPhoto(order.items.first.photo, size: 56),
                ),
                title: Text('${order.code} · ${order.statusLabel}'),
                subtitle: Text('${order.items.length} barang dari @${order.seller} · ${_date.format(order.createdAt)}'),
                trailing: Text(rupiah(order.total), style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: order.id)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final MarketplaceApi _api;
  late Future<Order> _order;

  @override
  void initState() {
    super.initState();
    _api = MarketplaceApi(context.read<CookieRequest>());
    _order = _api.order(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail pesanan')),
      body: AsyncView<Order>(
        future: _order,
        onRetry: () => setState(() => _order = _api.order(widget.orderId)),
        builder: (order) {
          final bold = const TextStyle(fontWeight: FontWeight.w700);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(order.code, style: Theme.of(context).textTheme.titleLarge),
              Text(order.statusLabel, style: const TextStyle(color: MarketColors.maroon)),
              const SizedBox(height: 16),
              for (final step in order.steps)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    step.done ? Icons.check_circle : (step.now ? Icons.radio_button_checked : Icons.circle_outlined),
                    color: step.done || step.now ? MarketColors.maroon : MarketColors.inkMuted,
                  ),
                  title: Text(step.label, style: step.now ? bold : null),
                  subtitle: step.meta.isEmpty ? null : Text(step.meta),
                ),
              const Divider(height: 32),
              for (final item in order.items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductPhoto(item.photo, size: 48),
                  ),
                  title: Text(item.name),
                  trailing: Text(rupiah(item.price)),
                ),
              const Divider(height: 32),
              Text('Dikirim ke', style: bold),
              Text('${order.recipient}\n${order.address}, ${order.city}'),
              const SizedBox(height: 12),
              Text('${order.courierLabel} · ${order.paymentLabel}'),
              if (order.trackingNumber.isNotEmpty) Text('No. resi ${order.trackingNumber}'),
              const SizedBox(height: 12),
              _row('Subtotal', rupiah(order.subtotal)),
              _row('Ongkir', rupiah(order.shippingCost)),
              _row('Total', rupiah(order.total), style: bold),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? style}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [Expanded(child: Text(label, style: style)), Text(value, style: style)]),
      );
}
