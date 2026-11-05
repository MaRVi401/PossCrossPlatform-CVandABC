import 'package:dio/dio.dart';
import '../models/cart_item_model.dart';

abstract class TransactionRemoteDataSource {
  Future<Map<String, dynamic>?> checkout({
    required int paymentMethodId,
    required double paidAmount,
    required double discountAmount,
    required List<CartItemModel> items,
    int? customerId,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final Dio dio;

  TransactionRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>?> checkout({
    required int paymentMethodId,
    required double paidAmount,
    required double discountAmount,
    required List<CartItemModel> items,
    int? customerId,
  }) async {
    try {
      final response = await dio.post(
        '/transactions',
        data: {
          'payment_method_id': paymentMethodId,
          'paid_amount': paidAmount,
          'discount_amount': discountAmount,
          if (customerId != null) 'customer_id': customerId,
          'items': items.map((e) => e.toTransactionJson()).toList(),
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal memproses transaksi checkout',
      );
    }
  }
}