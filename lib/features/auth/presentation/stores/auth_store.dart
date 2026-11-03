// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';

part 'auth_store.g.dart';

class AuthStore = _AuthStoreBase with _$AuthStore;

abstract class _AuthStoreBase with Store {
  final AuthRepository _repository;

  _AuthStoreBase(this._repository);

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  UserModel? currentUser;

  @observable
  bool isAuthenticated = false;

  @action
  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.login(email, password);

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        isAuthenticated = false;
        return false;
      },
      (user) {
        isLoading = false;
        currentUser = user;
        isAuthenticated = true;
        return true;
      },
    );
  }

  @action
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      address: address,
    );

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        isAuthenticated = false;
        return false;
      },
      (user) {
        isLoading = false;
        currentUser = user;
        isAuthenticated = true;
        return true;
      },
    );
  }

  @action
  Future<void> logout() async {
    isLoading = true;
    await _repository.logout();
    currentUser = null;
    isAuthenticated = false;
    isLoading = false;
  }

  @action
  Future<void> checkAuthStatus() async {
    isAuthenticated = await _repository.isLoggedIn();
    if (isAuthenticated) {
      currentUser = await _repository.getSavedUser();
    }
  }
}