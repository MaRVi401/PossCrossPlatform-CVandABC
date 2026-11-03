// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import '../../data/models/bundle_model.dart';
import '../../data/datasources/abc_remote_datasource.dart'; // <-- Gunakan ABCRemoteDataSource

part 'abc_store.g.dart';

class ABCStore = _ABCStoreBase with _$ABCStore;

abstract class _ABCStoreBase with Store {
  final ABCRemoteDataSource remoteDataSource;

  _ABCStoreBase(this.remoteDataSource);

  @observable
  ObservableList<BundleModel> bundles = ObservableList<BundleModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> generateBundles() async {
    isLoading = true;
    errorMessage = null;

    try {
      final result = await remoteDataSource.generateBundleRecommendations();
      bundles = ObservableList.of(result);
      isLoading = false;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      isLoading = false;
    }
  }
}