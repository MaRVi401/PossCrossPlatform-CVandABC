import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../../../shared/widgets/main_drawer.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    try {
      final response = await _dio.get('/reports/sales');
      if (response.statusCode == 200) {
        setState(() {
          _reports = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Penjualan')),
      drawer: const MainDrawer(currentRoute: '/reports'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reports.length,
              itemBuilder: (context, index) {
                final r = _reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEEF2FF),
                      child: Icon(Icons.receipt_long, color: Color(0xFF4F46E5)),
                    ),
                    title: Text('No. Trx: ${r['invoice_number'] ?? r['transaction_code'] ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Tanggal: ${r['created_at'] ?? '-'}'),
                    trailing: Text('Rp ${r['total_amount']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ),
                );
              },
            ),
    );
  }
}