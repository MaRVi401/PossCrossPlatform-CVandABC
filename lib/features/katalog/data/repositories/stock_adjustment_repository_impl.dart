import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/stock_adjustment_remote_datasource.dart';
import '../models/stock_adjustment_model.dart';

abstract class StockAdjustmentRepository {
  Future<Either<Failure, List<StockAdjustmentModel>>> getAdjustments();
  Future<Either<Failure, StockAdjustmentModel>> createAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    required String reason,
  });
}

class StockAdjustmentRepositoryImpl implements StockAdjustmentRepository {
  final StockAdjustmentRemoteDataSource remoteDataSource;

  StockAdjustmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<StockAdjustmentModel>>> getAdjustments() async {
    try {
      final result = await remoteDataSource.getAdjustments();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, StockAdjustmentModel>> createAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    required String reason,
  }) async {
    try {
      final result = await remoteDataSource.createAdjustment(
        productId: productId,
        adjustmentType: adjustmentType,
        quantity: quantity,
        reason: reason,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}