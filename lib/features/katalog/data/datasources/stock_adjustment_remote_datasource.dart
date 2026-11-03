import 'package:dio/dio.dart';
import '../models/stock_adjustment_model.dart';

abstract class StockAdjustmentRemoteDataSource {
  Future<List<StockAdjustmentModel>> getAdjustments();
  Future<StockAdjustmentModel> createAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    required String reason,
  });
}

class StockAdjustmentRemoteDataSourceImpl implements StockAdjustmentRemoteDataSource {
  final Dio dio;

  StockAdjustmentRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StockAdjustmentModel>> getAdjustments() async {
    try {
      final response = await dio.get('/stock-adjustments');
      final List data = response.data['data'] ?? [];
      return data.map((json) => StockAdjustmentModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat riwayat penyesuaian stok');
    }
  }

  @override
  Future<StockAdjustmentModel> createAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/stock-adjustments',
        data: {
          'product_id': productId,
          'adjustment_type': adjustmentType,
          'quantity': quantity,
          'reason': reason,
        },
      );
      return StockAdjustmentModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menyimpan penyesuaian stok');
    }
  }
}