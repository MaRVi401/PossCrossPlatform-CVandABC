// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository_impl.dart';

part 'category_store.g.dart';

class CategoryStore = _CategoryStoreBase with _$CategoryStore;

abstract class _CategoryStoreBase with Store {
  final CategoryRepository _repository;

  _CategoryStoreBase(this._repository);

  @observable
  ObservableList<CategoryModel> categories = ObservableList<CategoryModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @computed
  List<CategoryModel> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    return categories
        .where((c) => c.categoryName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.getCategories();

    result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
      },
      (data) {
        isLoading = false;
        categories = ObservableList.of(data);
      },
    );
  }

  @action
  Future<bool> addCategory(String name, String? description) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.createCategory(name, description);

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (category) {
        isLoading = false;
        categories.add(category);
        return true;
      },
    );
  }

  @action
  Future<bool> updateCategory(int id, String name, String? description) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.updateCategory(id, name, description);

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (updatedCategory) {
        isLoading = false;
        final index = categories.indexWhere((c) => c.categoryId == id);
        if (index != -1) {
          categories[index] = updatedCategory;
        }
        return true;
      },
    );
  }

  @action
  Future<bool> deleteCategory(int id) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.deleteCategory(id);

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (_) {
        isLoading = false;
        categories.removeWhere((c) => c.categoryId == id);
        return true;
      },
    );
  }
}