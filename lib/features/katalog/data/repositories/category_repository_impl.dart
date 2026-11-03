import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/category_remote_datasource.dart';
import '../models/category_model.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryModel>>> getCategories();
  Future<Either<Failure, CategoryModel>> createCategory(String name, String? description);
  Future<Either<Failure, CategoryModel>> updateCategory(int id, String name, String? description);
  Future<Either<Failure, void>> deleteCategory(int id);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> createCategory(String name, String? description) async {
    try {
      final category = await remoteDataSource.createCategory(name, description);
      return Right(category);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, CategoryModel>> updateCategory(int id, String name, String? description) async {
    try {
      final category = await remoteDataSource.updateCategory(id, name, description);
      return Right(category);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}