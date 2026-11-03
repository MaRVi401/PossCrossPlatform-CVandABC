import 'package:dio/dio.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory(String name, String? description);
  Future<CategoryModel> updateCategory(int id, String name, String? description);
  Future<void> deleteCategory(int id);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final Dio dio;

  CategoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await dio.get('/categories');
      final List data = response.data['data'] ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat kategori');
    }
  }

  @override
  Future<CategoryModel> createCategory(String name, String? description) async {
    try {
      final response = await dio.post(
        '/categories',
        data: {
          'category_name': name,
          'description': description,
        },
      );
      return CategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambah kategori');
    }
  }

  @override
  Future<CategoryModel> updateCategory(int id, String name, String? description) async {
    try {
      final response = await dio.put(
        '/categories/$id',
        data: {
          'category_name': name,
          'description': description,
        },
      );
      return CategoryModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengedit kategori');
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menghapus kategori');
    }
  }
}