import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import '../../../../app/di/injection.dart';
import '../../../../analytics/presentation/screens/cctv_analytics_screen.dart';
import '../stores/pos_store.dart';

class POSDashboardScreen extends StatefulWidget {
  const POSDashboardScreen({super.key});

  @override
  State<POSDashboardScreen> createState() => _POSDashboardScreenState();
}

class _POSDashboardScreenState extends State<POSDashboardScreen> {
  final POSStore store = sl<POSStore>();
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    store.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir POS & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Live Analytics CCTV',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CCTVAnalyticsScreen()),
              );
            },
          )
        ],
      ),
      body: Observer(
        builder: (_) {
          if (store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (store.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(store.errorMessage!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: store.loadProducts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                flex: 3,
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: store.products.length,
                  itemBuilder: (context, index) {
                    final product = store.products[index];
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => store.addToCart(product),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(currencyFormat.format(product.price), style: TextStyle(color: Colors.green[700])),
                              Chip(
                                label: Text('Stok: ${product.stock}', style: const TextStyle(fontSize: 10)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 350,
                color: Colors.grey[100],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Keranjang Belanja', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: store.cart.keys.length,
                        itemBuilder: (context, index) {
                          final product = store.cart.keys.elementAt(index);
                          final qty = store.cart[product]!;
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('${currencyFormat.format(product.price)} x $qty'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => store.removeFromCart(product),
                                ),
                                Text('$qty'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => store.addToCart(product),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          currencyFormat.format(store.totalPrice),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: store.cart.isEmpty
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Transaksi Berhasil Diproses!')),
                                );
                                store.clearCart();
                              },
                        child: const Text('Bayar / Checkout'),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}