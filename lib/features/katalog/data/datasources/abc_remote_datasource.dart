import 'package:dio/dio.dart';
import '../models/bundle_model.dart';

abstract class ABCRemoteDataSource {
  Future<BundleModel> generateBundleRecommendations();
}

class ABCRemoteDataSourceImpl implements ABCRemoteDataSource {
  final Dio dio;

  ABCRemoteDataSourceImpl({required this.dio});

  @override
  Future<BundleModel> generateBundleRecommendations() async {
    try {
      final response = await dio.get('/abc/generate-bundle');
      final responseData = response.data;
      final data = responseData['data'];

      return BundleModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final msg = e.response?.data['message'] ?? 'Gagal menghasilkan rekomendasi bundle';
        throw Exception(msg);
      }
      throw Exception('Gagal terhubung ke server untuk perhitungan ABC');
    }
  }
}