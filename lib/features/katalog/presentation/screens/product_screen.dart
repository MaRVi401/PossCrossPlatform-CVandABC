import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        setState(() {
          _products = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch products: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Produk')),
      drawer: const MainDrawer(currentRoute: '/products'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProducts,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final item = _products[index];
                  final stock = item['stock_quantity'] ?? item['stock'] ?? 0;
                  final minStock = item['min_stock_alert'] ?? 5;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item['image_url'] ?? 'https://via.placeholder.com/60',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2, size: 40),
                        ),
                      ),
                      title: Text(item['product_name'] ?? 'Produk', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKU: ${item['sku'] ?? '-'}', style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Rp ${(item['sell_price'] ?? 0).toString()}',
                              style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: stock <= minStock ? Colors.red.shade50 : const Color(0xFFECFDF5), // Emerald 50
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: stock <= minStock ? Colors.red : const Color(0xFF10B981)), // Emerald 500
                        ),
                        child: Text(
                          '$stock Unit',
                          style: TextStyle(
                            color: stock <= minStock ? Colors.red : const Color(0xFF059669), // Emerald 600
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}