import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductModel>>> getProducts();
  Future<Either<Failure, ProductModel>> createProduct({
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  });
  Future<Either<Failure, ProductModel>> updateProduct({
    required int productId,
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  });
  Future<Either<Failure, void>> deleteProduct(int id);
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductModel>>> getProducts() async {
    try {
      final products = await remoteDataSource.getProducts();
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> createProduct({
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  }) async {
    try {
      final product = await remoteDataSource.createProduct(
        categoryId: categoryId,
        sku: sku,
        productName: productName,
        buyPrice: buyPrice,
        sellPrice: sellPrice,
        stockQuantity: stockQuantity,
        imageFile: imageFile,
      );
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, ProductModel>> updateProduct({
    required int productId,
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  }) async {
    try {
      final product = await remoteDataSource.updateProduct(
        productId: productId,
        categoryId: categoryId,
        sku: sku,
        productName: productName,
        buyPrice: buyPrice,
        sellPrice: sellPrice,
        stockQuantity: stockQuantity,
        imageFile: imageFile,
      );
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}