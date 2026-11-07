import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio;

  static const String cctvBaseUrl = 'http://10.0.2.2:5000';

  ApiClient(this._dio) {
    _dio.options.baseUrl = 'http://10.0.2.2:8000/api/v1';
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get client => _dio;

  Dio get cctvClient {
    final cctvDio = Dio(
      BaseOptions(
        baseUrl: cctvBaseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        headers: {
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
    return cctvDio;
  }
}
