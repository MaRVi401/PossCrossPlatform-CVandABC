import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data['data'];
      final token = data['access_token'];
      final userData = data['user'];

      return UserModel.fromJson(userData, token: token);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final msg = e.response?.data['message'] ?? 'Terjadi kesalahan pada server';
        throw Exception(msg);
      }
      throw Exception('Gagal terhubung ke server');
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'address': address,
        },
      );

      final data = response.data['data'];
      final token = data['access_token'];
      final userData = data['user'];

      return UserModel.fromJson(userData, token: token);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final msg = e.response?.data['message'] ?? 'Validasi gagal';
        throw Exception(msg);
      }
      throw Exception('Gagal terhubung ke server');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (_) {
    }
  }
}