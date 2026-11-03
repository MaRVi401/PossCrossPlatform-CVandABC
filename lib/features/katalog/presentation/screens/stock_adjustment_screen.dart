import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class StockAdjustmentScreen extends StatefulWidget {
  const StockAdjustmentScreen({super.key});

  @override
  State<StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<StockAdjustmentScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  List<dynamic> _adjustments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdjustments();
  }

  Future<void> _fetchAdjustments() async {
    setState(() => _isLoading = true);
    try {
      final response = await _dio.get('/stock-adjustments');
      if (response.statusCode == 200) {
        setState(() {
          _adjustments = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch adjustments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penyesuaian Stok')),
      drawer: const MainDrawer(currentRoute: '/stock-adjustments'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _adjustments.length,
              itemBuilder: (context, index) {
                final adj = _adjustments[index];
                final type = adj['type'] ?? 'in';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: type == 'in' ? Colors.green.shade50 : Colors.orange.shade50,
                      child: Icon(type == 'in' ? Icons.add : Icons.remove, color: type == 'in' ? Colors.green : Colors.orange),
                    ),
                    title: Text(adj['product']?['product_name'] ?? 'Penyesuaian Stok', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Alasan: ${adj['reason'] ?? '-'}'),
                    trailing: Text(
                      '${type == 'in' ? '+' : '-'}${adj['quantity']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: type == 'in' ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}