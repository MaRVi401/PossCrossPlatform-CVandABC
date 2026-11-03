// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';
import '../../data/models/stock_adjustment_model.dart';
import '../../data/repositories/stock_adjustment_repository_impl.dart';

part 'stock_adjustment_store.g.dart';

class StockAdjustmentStore = _StockAdjustmentStoreBase with _$StockAdjustmentStore;

abstract class _StockAdjustmentStoreBase with Store {
  final StockAdjustmentRepository repository;

  _StockAdjustmentStoreBase(this.repository);

  @observable
  ObservableList<StockAdjustmentModel> adjustments = ObservableList<StockAdjustmentModel>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> fetchAdjustments() async {
    isLoading = true;
    errorMessage = null;

    final result = await repository.getAdjustments();
    result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
      },
      (data) {
        isLoading = false;
        adjustments = ObservableList.of(data);
      },
    );
  }

  @action
  Future<bool> createAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    required String reason,
  }) async {
    isLoading = true;
    errorMessage = null;

    final result = await repository.createAdjustment(
      productId: productId,
      adjustmentType: adjustmentType,
      quantity: quantity,
      reason: reason,
    );

    return result.fold(
      (failure) {
        isLoading = false;
        errorMessage = failure.message;
        return false;
      },
      (newAdjustment) {
        isLoading = false;
        adjustments.insert(0, newAdjustment);
        return true;
      },
    );
  }
}