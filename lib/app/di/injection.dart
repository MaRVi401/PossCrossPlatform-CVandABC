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
  // ----------------------------------------------------
}