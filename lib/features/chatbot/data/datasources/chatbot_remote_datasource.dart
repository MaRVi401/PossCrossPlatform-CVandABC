
import '../../../../core/network/api_client.dart';
import 'package:dio/dio.dart';

abstract class ChatbotRemoteDataSource {
  Future<String> sendMessage({
    required String message,
    List<Map<String, dynamic>>? history,
  });
}

class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final ApiClient apiClient;

  ChatbotRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<String> sendMessage({
    required String message,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final response = await apiClient.client.post(
        '/chatbot/chat',
        data: {
          'message': message,
          if (history != null && history.isNotEmpty)
            'history': history,
        },
      );

      if (response.statusCode == 200 &&
          response.data['status'] == 'success') {
        return response.data['reply'] as String;
      }

      throw Exception(
        response.data['message'] ?? 'Gagal memproses pesan AI.',
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.message ??
            'Terjadi kesalahan koneksi ke server.',
      );
    }
  }
}
