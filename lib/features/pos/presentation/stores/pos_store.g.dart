// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pos_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$PosStore on _PosStoreBase, Store {
  Computed<double>? _$subtotalComputed;

  @override
  double get subtotal =>
      (_$subtotalComputed ??= Computed<double>(() => super.subtotal,
              name: '_PosStoreBase.subtotal'))
          .value;
  Computed<double>? _$finalTotalComputed;

  @override
  double get finalTotal =>
      (_$finalTotalComputed ??= Computed<double>(() => super.finalTotal,
              name: '_PosStoreBase.finalTotal'))
          .value;

  late final _$cartAtom = Atom(name: '_PosStoreBase.cart', context: context);

  @override
  ObservableList<CartItemModel> get cart {
    _$cartAtom.reportRead();
    return super.cart;
  }

  @override
  set cart(ObservableList<CartItemModel> value) {
    _$cartAtom.reportWrite(value, super.cart, () {
      super.cart = value;
    });
  }

  late final _$discountAmountAtom =
      Atom(name: '_PosStoreBase.discountAmount', context: context);

  @override
  double get discountAmount {
    _$discountAmountAtom.reportRead();
    return super.discountAmount;
  }

  @override
  set discountAmount(double value) {
    _$discountAmountAtom.reportWrite(value, super.discountAmount, () {
      super.discountAmount = value;
    });
  }

  late final _$activeBundleAtom =
      Atom(name: '_PosStoreBase.activeBundle', context: context);

  @override
  BundleModel? get activeBundle {
    _$activeBundleAtom.reportRead();
    return super.activeBundle;
  }

  @override
  set activeBundle(BundleModel? value) {
    _$activeBundleAtom.reportWrite(value, super.activeBundle, () {
      super.activeBundle = value;
    });
  }

  late final _$isSubmittingAtom =
      Atom(name: '_PosStoreBase.isSubmitting', context: context);

  @override
  bool get isSubmitting {
    _$isSubmittingAtom.reportRead();
    return super.isSubmitting;
  }

  @override
  set isSubmitting(bool value) {
    _$isSubmittingAtom.reportWrite(value, super.isSubmitting, () {
      super.isSubmitting = value;
    });
  }

  late final _$errorMessageAtom =
      Atom(name: '_PosStoreBase.errorMessage', context: context);

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

  late final _$checkoutAsyncAction =
      AsyncAction('_PosStoreBase.checkout', context: context);

  @override
  Future<Map<String, dynamic>?> checkout(
      {required int paymentMethodId, required double paidAmount}) {
    return _$checkoutAsyncAction.run(() => super
        .checkout(paymentMethodId: paymentMethodId, paidAmount: paidAmount));
  }

  late final _$_PosStoreBaseActionController =
      ActionController(name: '_PosStoreBase', context: context);

  @override
  void addToCart(ProductModel product) {
    final _$actionInfo = _$_PosStoreBaseActionController.startAction(
        name: '_PosStoreBase.addToCart');
    try {
      return super.addToCart(product);
    } finally {
      _$_PosStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void updateQty(int index, int change) {
    final _$actionInfo = _$_PosStoreBaseActionController.startAction(
        name: '_PosStoreBase.updateQty');
    try {
      return super.updateQty(index, change);
    } finally {
      _$_PosStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearCart() {
    final _$actionInfo = _$_PosStoreBaseActionController.startAction(
        name: '_PosStoreBase.clearCart');
    try {
      return super.clearCart();
    } finally {
      _$_PosStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  bool applyABCBundle(BundleModel bundle, List<ProductModel> products) {
    final _$actionInfo = _$_PosStoreBaseActionController.startAction(
        name: '_PosStoreBase.applyABCBundle');
    try {
      return super.applyABCBundle(bundle, products);
    } finally {
      _$_PosStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
cart: ${cart},
discountAmount: ${discountAmount},
activeBundle: ${activeBundle},
isSubmitting: ${isSubmitting},
errorMessage: ${errorMessage},
subtotal: ${subtotal},
finalTotal: ${finalTotal}
    ''';
  }
}
