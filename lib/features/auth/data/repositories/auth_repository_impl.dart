import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  });
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getSavedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences prefs;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.prefs,
  });

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await _saveSession(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
      await _saveSession(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } finally {
      await prefs.remove('auth_token');
      await prefs.remove('user_id');
      await prefs.remove('role_id');
      await prefs.remove('role_name');
      await prefs.remove('user_name');
      await prefs.remove('user_email');
    }
    return const Right(null);
  }

  @override
  Future<bool> isLoggedIn() async {
    return prefs.containsKey('auth_token');
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final token = prefs.getString('auth_token');
    if (token == null) return null;

    return UserModel(
      userId: prefs.getInt('user_id') ?? 0,
      roleId: prefs.getInt('role_id') ?? 0,
      roleName: prefs.getString('role_name') ?? '',
      name: prefs.getString('user_name') ?? '',
      email: prefs.getString('user_email') ?? '',
      accessToken: token,
    );
  }

  Future<void> _saveSession(UserModel user) async {
    if (user.accessToken != null) {
      await prefs.setString('auth_token', user.accessToken!);
      await prefs.setInt('user_id', user.userId);
      await prefs.setInt('role_id', user.roleId);
      await prefs.setString('role_name', user.roleName);
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
    }
  }
}