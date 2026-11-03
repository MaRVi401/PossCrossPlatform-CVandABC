import 'package:dio/dio.dart';
import 'dart:io';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct({
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  });
  Future<ProductModel> updateProduct({
    required int productId,
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  });
  Future<void> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get('/products');
      final List data = response.data['data'] ?? [];
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat produk');
    }
  }

  @override
  Future<ProductModel> createProduct({
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'category_id': categoryId,
        'sku': sku,
        'product_name': productName,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'stock_quantity': stockQuantity,
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last),
        ));
      }

      final response = await dio.post('/products', data: formData);
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambah produk');
    }
  }

  @override
  Future<ProductModel> updateProduct({
    required int productId,
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  }) async {
    try {
      // Laravel membutuhkan _method PUT jika mengirim FormData dengan file
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'category_id': categoryId,
        'sku': sku,
        'product_name': productName,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'stock_quantity': stockQuantity,
      });

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last),
        ));
      }

      final response = await dio.post('/products/$productId', data: formData);
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui produk');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus produk');
    }
  }
}