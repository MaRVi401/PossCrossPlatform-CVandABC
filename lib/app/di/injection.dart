import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/auth/presentation/stores/auth_store.dart';
import '../../features/pos/data/datasources/pos_remote_datasource.dart';
import '../../features/pos/data/repositories/pos_repository_impl.dart';
import '../../features/pos/domain/repositories/pos_repository.dart';
import '../../features/pos/domain/usecases/get_products_usecase.dart';
import '../../features/pos/presentation/stores/pos_store.dart';

final sl = GetIt.instance;

void setupDependencyInjection(String baseUrl) {
  // Core Network Client
  sl.registerLazySingleton<Dio>(() => Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Accept': 'application/json'},
        ),
      ));

  // Data Sources
  sl.registerLazySingleton<POSRemoteDataSource>(
    () => POSRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<POSRepository>(
    () => POSRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));

  // MobX Stores
  sl.registerLazySingleton(() => AuthStore(dio: sl()));
  sl.registerFactory(() => POSStore(getProductsUseCase: sl()));
}