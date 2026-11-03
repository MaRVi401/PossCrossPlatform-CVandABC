// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_adjustment_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$StockAdjustmentStore on _StockAdjustmentStoreBase, Store {
  late final _$adjustmentsAtom =
      Atom(name: '_StockAdjustmentStoreBase.adjustments', context: context);

  @override
  ObservableList<StockAdjustmentModel> get adjustments {
    _$adjustmentsAtom.reportRead();
    return super.adjustments;
  }

  @override
  set adjustments(ObservableList<StockAdjustmentModel> value) {
    _$adjustmentsAtom.reportWrite(value, super.adjustments, () {
      super.adjustments = value;
    });
  }

  late final _$isLoadingAtom =
      Atom(name: '_StockAdjustmentStoreBase.isLoading', context: context);

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
      Atom(name: '_StockAdjustmentStoreBase.errorMessage', context: context);

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

  late final _$fetchAdjustmentsAsyncAction = AsyncAction(
      '_StockAdjustmentStoreBase.fetchAdjustments',
      context: context);

  @override
  Future<void> fetchAdjustments() {
    return _$fetchAdjustmentsAsyncAction.run(() => super.fetchAdjustments());
  }

  late final _$createAdjustmentAsyncAction = AsyncAction(
      '_StockAdjustmentStoreBase.createAdjustment',
      context: context);

  @override
  Future<bool> createAdjustment(
      {required int productId,
      required String adjustmentType,
      required int quantity,
      required String reason}) {
    return _$createAdjustmentAsyncAction.run(() => super.createAdjustment(
        productId: productId,
        adjustmentType: adjustmentType,
        quantity: quantity,
        reason: reason));
  }

  @override
  String toString() {
    return '''
adjustments: ${adjustments},
isLoading: ${isLoading},
errorMessage: ${errorMessage}
    ''';
  }
}
