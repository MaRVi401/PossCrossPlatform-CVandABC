import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  List<dynamic> _products = [];
  final Map<int, int> _cart = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _products = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _totalPrice {
    int total = 0;
    _cart.forEach((id, qty) {
      final item = _products.firstWhere((p) => (p['product_id'] ?? p['id']) == id, orElse: () => null);
      if (item != null) {
        final price = (item['sell_price'] as num).toInt();
        total += price * qty;
      }
    });
    return total;
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;

    final items = _cart.entries.map((e) => {'product_id': e.key, 'quantity': e.value}).toList();

    try {
      final response = await _dio.post('/transactions', data: {
        'items': items,
        'total_amount': _totalPrice,
      });

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi Berhasil Disimpan!'), backgroundColor: Colors.green),
        );
        setState(() => _cart.clear());
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasir (POS)')),
      drawer: const MainDrawer(currentRoute: '/pos'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final p = _products[index];
                      final id = p['product_id'] ?? p['id'];
                      final qty = _cart[id] ?? 0;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(child: Icon(Icons.fastfood, size: 40, color: Colors.indigo)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(p['product_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Rp ${p['sell_price']}', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: qty > 0 ? () => setState(() => _cart[id] = qty - 1) : null,
                                  ),
                                  Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    color: Colors.indigo,
                                    onPressed: () => setState(() => _cart[id] = qty + 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('Rp $_totalPrice', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _cart.isNotEmpty ? _checkout : null,
                        child: const Text('PROSES TRANSAKSI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}