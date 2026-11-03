// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:mobx/mobx.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';

part 'product_store.g.dart';

class ProductStore = _ProductStoreBase with _$ProductStore;

abstract class _ProductStoreBase with Store {
  final ProductRepository _repository;

  _ProductStoreBase(this._repository);

  @observable
  ObservableList<ProductModel> products = ObservableList<ProductModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  String searchQuery = '';

  @computed
  List<ProductModel> get filteredProducts {
    if (searchQuery.isEmpty) return products;
    return products
        .where((p) =>
            p.productName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            p.sku.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @action
  void setSearchQuery(String query) {
    searchQuery = query;
  }

  @action
  Future<void> fetchProducts() async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.getProducts();

    result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
      },
      (data) {
        isLoading = false;
        products = ObservableList.of(data);
      },
    );
  }

  @action
  Future<bool> addProduct({
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  }) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.createProduct(
      categoryId: categoryId,
      sku: sku,
      productName: productName,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      stockQuantity: stockQuantity,
      imageFile: imageFile,
    );

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (product) {
        isLoading = false;
        products.add(product);
        return true;
      },
    );
  }

  @action
  Future<bool> updateProduct({
    required int productId,
    required int categoryId,
    required String sku,
    required String productName,
    required double buyPrice,
    required double sellPrice,
    required int stockQuantity,
    File? imageFile,
  }) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.updateProduct(
      productId: productId,
      categoryId: categoryId,
      sku: sku,
      productName: productName,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      stockQuantity: stockQuantity,
      imageFile: imageFile,
    );

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (updatedProduct) {
        isLoading = false;
        final index = products.indexWhere((p) => p.productId == productId);
        if (index != -1) {
          products[index] = updatedProduct;
        }
        return true;
      },
    );
  }

  @action
  Future<bool> deleteProduct(int id) async {
    isLoading = true;
    errorMessage = null;

    final result = await _repository.deleteProduct(id);

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (_) {
        isLoading = false;
        products.removeWhere((p) => p.productId == id);
        return true;
      },
    );
  }
}