import 'package:dio/dio.dart';
import '../models/bundle_model.dart';

abstract class ABCRemoteDataSource {
  Future<List<BundleModel>> generateBundleRecommendations();
}

class ABCRemoteDataSourceImpl implements ABCRemoteDataSource {
  final Dio dio;

  ABCRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BundleModel>> generateBundleRecommendations() async {
    try {
      final response = await dio.get('/abc/generate-bundle');
      
      // Sesuai dengan struktur respons API Laravel:
      // { "success": true, "message": "...", "data": [...] }
      final responseData = response.data;
      final data = responseData['data'];

      if (data is List) {
        return data.map((json) => BundleModel.fromJson(json)).toList();
      } else if (data is Map<String, dynamic>) {
        // Jika server mengembalikan objek tunggal
        return [BundleModel.fromJson(data)];
      }
      
      return [];
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final msg = e.response?.data['message'] ?? 'Gagal menghasilkan rekomendasi bundle';
        throw Exception(msg);
      }
      throw Exception('Gagal terhubung ke server untuk perhitungan ABC');
    }
  }
}