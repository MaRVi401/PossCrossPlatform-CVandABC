import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_entity.dart';

abstract class POSRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, bool>> submitTransaction(List<ProductEntity> items, double total);
}