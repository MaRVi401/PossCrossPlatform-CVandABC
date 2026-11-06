import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/stores/auth_store.dart';

// Katalog
import '../../features/katalog/data/datasources/category_remote_datasource.dart';
import '../../features/katalog/data/repositories/category_repository_impl.dart';
import '../../features/katalog/presentation/stores/category_store.dart';

// Produk Imports
import '../../features/katalog/data/datasources/product_remote_datasource.dart';
import '../../features/katalog/data/repositories/product_repository_impl.dart';
import '../../features/katalog/presentation/stores/product_store.dart';

// Pos Generate ABC
import '../../features/katalog/data/datasources/abc_remote_datasource.dart';
import '../../features/katalog/presentation/stores/abc_store.dart';

// Stock Adjustment
import '../../features/katalog/data/datasources/stock_adjustment_remote_datasource.dart';
import '../../features/katalog/data/repositories/stock_adjustment_repository_impl.dart';
import '../../features/katalog/presentation/stores/stock_adjustment_store.dart';

// Pos Transaction
import '../../features/pos/data/datasources/transaction_remote_datasource.dart';
import '../../features/pos/presentation/stores/pos_store.dart';

// Reports
import '../../features/reports/presentation/stores/sales_report_store.dart';

final sl = GetIt.instance;

Future<void> initInjections() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Network Client
  sl.registerLazySingleton<Dio>(() => Dio());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // Auth Injection
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), prefs: sl()),
  );
  sl.registerLazySingleton<AuthStore>(() => AuthStore(sl()));

  //  Category Injection
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CategoryStore>(
    () => CategoryStore(sl()),
  );

  // Product Injection
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductStore>(() => ProductStore(sl()));

  // ABC Injection
  sl.registerLazySingleton<ABCRemoteDataSource>(
    () => ABCRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );
  sl.registerLazySingleton<ABCStore>(
    () => ABCStore(sl<ABCRemoteDataSource>()),
  );

  // Stock Adjustment Injection
  sl.registerLazySingleton<StockAdjustmentRemoteDataSource>(
    () => StockAdjustmentRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );
  sl.registerLazySingleton<StockAdjustmentRepository>(
    () => StockAdjustmentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StockAdjustmentStore>(
    () => StockAdjustmentStore(sl()),
  );

  // Pos Transaction Injection
  sl.registerLazySingleton<TransactionRemoteDataSource>(
    () => TransactionRemoteDataSourceImpl(dio: sl<ApiClient>().client),
  );
  sl.registerLazySingleton<PosStore>(
    () => PosStore(sl()),
  );

  // Sales Report Injection
  sl.registerLazySingleton<SalesReportStore>(() => SalesReportStore());
}
