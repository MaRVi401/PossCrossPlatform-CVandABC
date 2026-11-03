import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class AbcOptimizationScreen extends StatefulWidget {
  const AbcOptimizationScreen({super.key});

  @override
  State<AbcOptimizationScreen> createState() => _AbcOptimizationScreenState();
}

class _AbcOptimizationScreenState extends State<AbcOptimizationScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  Map<String, dynamic>? _abcData;
  bool _isLoading = false;

  Future<void> _runAbc() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/abc/generate-bundle');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _abcData = response.data['data'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal optimasi ABC: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Bundling (ABC)')),
      drawer: const MainDrawer(currentRoute: '/abc'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF4F46E5)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🐝 Artificial Bee Colony AI', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Optimasi Paket Promo Fast-Moving & Slow-Moving',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                    onPressed: _isLoading ? null : _runAbc,
                    icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.rocket_launch),
                    label: Text(_isLoading ? 'Memproses Lebah...' : 'Jalankan Optimasi AI'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_abcData != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hasil Pasangan Bundling Diskon:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      Text('• Fast Product: ${_abcData!['fast_product']?['product_name']}'),
                      Text('• Slow Product: ${_abcData!['slow_product']?['product_name']}'),
                      const SizedBox(height: 8),
                      Text('Harga Normal: Rp ${_abcData!['normal_price']}'),
                      Text('Diskon Lebah: Rp ${_abcData!['discount_amount']}', style: const TextStyle(color: Colors.red)),
                      Text('Harga Promo: Rp ${_abcData!['promo_price']}',
                          style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}