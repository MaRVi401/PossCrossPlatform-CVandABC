// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$POSStore on _POSStore, Store {
  Computed<double>? _$totalPriceComputed;

  @override
  double get totalPrice =>
      (_$totalPriceComputed ??= Computed<double>(() => super.totalPrice,
              name: '_POSStore.totalPrice'))
          .value;

  late final _$productsAtom =
      Atom(name: '_POSStore.products', context: context);

  @override
  ObservableList<ProductEntity> get products {
    _$productsAtom.reportRead();
    return super.products;
  }

  @override
  set products(ObservableList<ProductEntity> value) {
    _$productsAtom.reportWrite(value, super.products, () {
      super.products = value;
    });
  }

  late final _$cartAtom = Atom(name: '_POSStore.cart', context: context);

  @override
  ObservableMap<ProductEntity, int> get cart {
    _$cartAtom.reportRead();
    return super.cart;
  }

  @override
  set cart(ObservableMap<ProductEntity, int> value) {
    _$cartAtom.reportWrite(value, super.cart, () {
      super.cart = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_POSStore.isLoading', context: context);

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
      Atom(name: '_POSStore.errorMessage', context: context);

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

  late final _$loadProductsAsyncAction =
      AsyncAction('_POSStore.loadProducts', context: context);

  @override
  Future<void> loadProducts() {
    return _$loadProductsAsyncAction.run(() => super.loadProducts());
  }

  late final _$_POSStoreActionController =
      ActionController(name: '_POSStore', context: context);

  @override
  void addToCart(ProductEntity product) {
    final _$actionInfo =
        _$_POSStoreActionController.startAction(name: '_POSStore.addToCart');
    try {
      return super.addToCart(product);
    } finally {
      _$_POSStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeFromCart(ProductEntity product) {
    final _$actionInfo = _$_POSStoreActionController.startAction(
        name: '_POSStore.removeFromCart');
    try {
      return super.removeFromCart(product);
    } finally {
      _$_POSStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCart() {
    final _$actionInfo =
        _$_POSStoreActionController.startAction(name: '_POSStore.clearCart');
    try {
      return super.clearCart();
    } finally {
      _$_POSStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
products: ${products},
cart: ${cart},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
totalPrice: ${totalPrice}
    ''';
  }
}
