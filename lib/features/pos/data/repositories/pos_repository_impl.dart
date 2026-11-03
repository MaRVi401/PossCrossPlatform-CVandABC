import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/pos_repository.dart';
import '../datasources/pos_remote_datasource.dart';
import '../models/product_model.dart';

class POSRepositoryImpl implements POSRepository {
  final POSRemoteDataSource remoteDataSource;
  POSRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      final models = await remoteDataSource.fetchProducts();
      return Right(models);
    } catch (e) {
      return Left(ServerFailure("Gagal mengambil data produk: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, bool>> submitTransaction(List<ProductEntity> items, double total) async {
    try {
      // Ubah List<ProductEntity> menjadi List<ProductModel>
      final productModels = items.map((item) => ProductModel.fromEntity(item)).toList();
      final success = await remoteDataSource.postTransaction(productModels, total);
      return Right(success);
    } catch (e) {
      return Left(ServerFailure("Gagal memproses transaksi"));
    }
  }
}