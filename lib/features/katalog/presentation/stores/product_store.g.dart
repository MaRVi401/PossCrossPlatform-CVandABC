// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ProductStore on _ProductStoreBase, Store {
  Computed<List<ProductModel>>? _$filteredProductsComputed;

  @override
  List<ProductModel> get filteredProducts => (_$filteredProductsComputed ??=
          Computed<List<ProductModel>>(() => super.filteredProducts,
              name: '_ProductStoreBase.filteredProducts'))
      .value;

  late final _$productsAtom =
      Atom(name: '_ProductStoreBase.products', context: context);

  @override
  ObservableList<ProductModel> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<ProductModel> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_ProductStoreBase.isLoading', context: context);

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
      Atom(name: '_ProductStoreBase.errorMessage', context: context);

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
      Atom(name: '_ProductStoreBase.searchQuery', context: context);

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

  late final _$fetchProductsAsyncAction =
      AsyncAction('_ProductStoreBase.fetchProducts', context: context);

  @override
  Future<void> fetchProducts() {
    return _$fetchProductsAsyncAction.run(() => super.fetchProducts());
  }

  late final _$addProductAsyncAction =
      AsyncAction('_ProductStoreBase.addProduct', context: context);

  @override
  Future<bool> addProduct(
      {required int categoryId,
      required String sku,
      required String productName,
      required double buyPrice,
      required double sellPrice,
      required int stockQuantity,
      File? imageFile}) {
    return _$addProductAsyncAction.run(() => super.addProduct(
        categoryId: categoryId,
        sku: sku,
        productName: productName,
        buyPrice: buyPrice,
        sellPrice: sellPrice,
        stockQuantity: stockQuantity,
        imageFile: imageFile));
  }

  late final _$updateProductAsyncAction =
      AsyncAction('_ProductStoreBase.updateProduct', context: context);

  @override
  Future<bool> updateProduct(
      {required int productId,
      required int categoryId,
      required String sku,
      required String productName,
      required double buyPrice,
      required double sellPrice,
      required int stockQuantity,
      File? imageFile}) {
    return _$updateProductAsyncAction.run(() => super.updateProduct(
        productId: productId,
        categoryId: categoryId,
        sku: sku,
        productName: productName,
        buyPrice: buyPrice,
        sellPrice: sellPrice,
        stockQuantity: stockQuantity,
        imageFile: imageFile));
  }

  late final _$deleteProductAsyncAction =
      AsyncAction('_ProductStoreBase.deleteProduct', context: context);

  @override
  Future<bool> deleteProduct(int id) {
    return _$deleteProductAsyncAction.run(() => super.deleteProduct(id));
  }

  late final _$_ProductStoreBaseActionController =
      ActionController(name: '_ProductStoreBase', context: context);

  @override
  void setSearchQuery(String query) {
    final _$actionInfo = _$_ProductStoreBaseActionController.startAction(
        name: '_ProductStoreBase.setSearchQuery');
    try {
      return super.setSearchQuery(query);
    } finally {
      _$_ProductStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
products: ${products},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
searchQuery: ${searchQuery},
filteredProducts: ${filteredProducts}
    ''';
  }
}
