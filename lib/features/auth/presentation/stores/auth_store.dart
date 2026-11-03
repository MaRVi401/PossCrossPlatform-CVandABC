import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Import untuk debugPrint
import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

// ignore: library_private_types_in_public_api
class AuthStore = _AuthStore with _$AuthStore;

abstract class _AuthStore with Store {
  final Dio dio;

  _AuthStore({required this.dio});

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String? token;

  @action
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;

    try {
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      // Mengganti print() dengan debugPrint()
      debugPrint('RESPONSE LARAVEL LOGIN: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        token = responseData['token'] ??
            responseData['access_token'] ??
            responseData['data']?['token'] ??
            responseData['data']?['access_token'] ??
            responseData['authorisation']?['token'] ??
            responseData['result']?['token'];

        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
          isLoading = false;
          return true;
        }
      }

      errorMessage = 'Format response token tidak sesuai';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        errorMessage = 'Email atau password salah';
      } else {
        errorMessage = e.response?.data['message'] ?? 'Gagal terhubung ke server';
      }
    } catch (e) {
      errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    }

    isLoading = false;
    return false;
  }
}