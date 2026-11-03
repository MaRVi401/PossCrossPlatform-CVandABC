// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CategoryStore on _CategoryStoreBase, Store {
  Computed<List<CategoryModel>>? _$filteredCategoriesComputed;

  @override
  List<CategoryModel> get filteredCategories =>
      (_$filteredCategoriesComputed ??= Computed<List<CategoryModel>>(
              () => super.filteredCategories,
              name: '_CategoryStoreBase.filteredCategories'))
          .value;

  late final _$categoriesAtom =
      Atom(name: '_CategoryStoreBase.categories', context: context);

  @override
  ObservableList<CategoryModel> get categories {
    _$categoriesAtom.reportRead();
    return super.categories;
  }

  @override
  set categories(ObservableList<CategoryModel> value) {
    _$categoriesAtom.reportWrite(value, super.categories, () {
      super.categories = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_CategoryStoreBase.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_CategoryStoreBase.errorMessage', context: context);

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$searchQueryAtom =
      Atom(name: '_CategoryStoreBase.searchQuery', context: context);

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$fetchCategoriesAsyncAction =
      AsyncAction('_CategoryStoreBase.fetchCategories', context: context);

  @override
  Future<void> fetchCategories() {
    return _$fetchCategoriesAsyncAction.run(() => super.fetchCategories());
  }

  late final _$addCategoryAsyncAction =
      AsyncAction('_CategoryStoreBase.addCategory', context: context);

  @override
  Future<bool> addCategory(String name, String? description) {
    return _$addCategoryAsyncAction
        .run(() => super.addCategory(name, description));
  }

  late final _$updateCategoryAsyncAction =
      AsyncAction('_CategoryStoreBase.updateCategory', context: context);

  @override
  Future<bool> updateCategory(int id, String name, String? description) {
    return _$updateCategoryAsyncAction
        .run(() => super.updateCategory(id, name, description));
  }

  late final _$deleteCategoryAsyncAction =
      AsyncAction('_CategoryStoreBase.deleteCategory', context: context);

  @override
  Future<bool> deleteCategory(int id) {
    return _$deleteCategoryAsyncAction.run(() => super.deleteCategory(id));
  }

  late final _$_CategoryStoreBaseActionController =
      ActionController(name: '_CategoryStoreBase', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_CategoryStoreBaseActionController.startAction(
        name: '_CategoryStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_CategoryStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
categories: ${categories},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
filteredCategories: ${filteredCategories}
    ''';
  }
}
