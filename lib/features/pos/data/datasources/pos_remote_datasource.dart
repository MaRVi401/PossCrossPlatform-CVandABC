import 'package:dio/dio.dart';
import '../models/product_model.dart';

abstract class POSRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
  Future<bool> postTransaction(List<ProductModel> items, double total);
}

class POSRemoteDataSourceImpl implements POSRemoteDataSource {
  final Dio dio;
  POSRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> fetchProducts() async {
    final response = await dio.get('/products');
    final data = response.data['data'] as List;
    return data.map((item) => ProductModel.fromJson(item)).toList();
  }

  @override
  Future<bool> postTransaction(List<ProductModel> items, double total) async {
    final response = await dio.post('/transactions', data: {
      'items': items.map((e) => e.toJson()).toList(),
      'total_price': total,
    });
    return response.statusCode == 200 || response.statusCode == 201;
  }
}