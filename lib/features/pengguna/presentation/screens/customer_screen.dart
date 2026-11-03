import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  List<dynamic> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await _dio.get('/customers');
      if (response.statusCode == 200) {
        setState(() {
          _customers = response.data['data'] ?? [];
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
      appBar: AppBar(title: const Text('Data Pelanggan')),
      drawer: const MainDrawer(currentRoute: '/customers'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final c = _customers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEEF2FF),
                      child: Icon(Icons.person, color: Color(0xFF4F46E5)),
                    ),
                    title: Text(c['name'] ?? c['customer_name'] ?? 'Pelanggan', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('No HP: ${c['phone'] ?? '-'} | Email: ${c['email'] ?? '-'}'),
                  ),
                );
              },
            ),
    );
  }
}