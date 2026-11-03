import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/main_drawer.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1'));
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _dio.get(
        '/categories',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        setState(() {
          if (data is Map && data.containsKey('data')) {
            _categories = data['data'] ?? [];
          } else if (data is List) {
            _categories = data;
          } else {
            _categories = [];
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat data (Status: ${response.statusCode})';
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.response?.statusCode == 401) {
          _errorMessage = 'Sesi telah berakhir, silakan login kembali.';
        } else {
          _errorMessage = e.response?.data['message'] ?? 'Gagal terhubung ke backend Laravel.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori Produk'),
        elevation: 1,
      ),
      drawer: const MainDrawer(currentRoute: '/categories'),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat Kategori Produk...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 14), // Disesuaikan ke Hex Slate 700
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchCategories,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCategories,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada data kategori tersimpan di database.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tarik ke bawah untuk memperbarui.',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final String catName = cat['category_name'] ?? cat['name'] ?? 'Kategori #${cat['id'] ?? index + 1}';
          final String catCode = cat['category_code'] ?? cat['code'] ?? 'CAT-${cat['id'] ?? index + 1}';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEEF2FF),
                child: Icon(Icons.category, color: Color(0xFF4F46E5)),
              ),
              title: Text(
                catName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                'Kode: $catCode',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }
}