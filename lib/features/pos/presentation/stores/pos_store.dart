// ignore_for_file: library_private_types_in_public_api

import 'package:mobx/mobx.dart';

import '../../../katalog/data/models/product_model.dart';
import '../../../katalog/data/models/bundle_model.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/datasources/transaction_remote_datasource.dart';

part 'pos_store.g.dart';

class PosStore = _PosStoreBase with _$PosStore;

abstract class _PosStoreBase with Store {
  final TransactionRemoteDataSource remoteDataSource;

  _PosStoreBase(this.remoteDataSource);

  @observable
  ObservableList<CartItemModel> cart = ObservableList<CartItemModel>();

  @observable
  double discountAmount = 0.0;

  @observable
  BundleModel? activeBundle;

  @observable
  bool isSubmitting = false;

  @observable
  String? errorMessage;

  @computed
  double get subtotal => cart.fold(0.0, (sum, item) => sum + item.subtotal);

  @computed
  double get finalTotal {
    final total = subtotal - discountAmount;
    return total < 0 ? 0 : total;
  }

  @action
  void addToCart(ProductModel product) {
    if (product.stockQuantity <= 0) return;

    final index = cart.indexWhere(
      (item) => item.productId == product.productId,
    );

    if (index > -1) {
      if (cart[index].quantity + 1 <= product.stockQuantity) {
        cart[index].quantity++;
        cart = ObservableList.of(cart);
      }
    } else {
      cart.add(
        CartItemModel(
          productId: product.productId,
          productName: product.productName,
          sellPrice: product.sellPrice,
          stockQuantity: product.stockQuantity,
          quantity: 1,
        ),
      );
    }
  }

  @action
  void updateQty(int index, int change) {
    if (index < 0 || index >= cart.length) return;

    final item = cart[index];
    final newQty = item.quantity + change;

    if (newQty <= 0) {
      cart.removeAt(index);
    } else if (newQty <= item.stockQuantity) {
      item.quantity = newQty;
      cart = ObservableList.of(cart);
    }
  }

  @action
  void clearCart() {
    cart.clear();
    discountAmount = 0.0;
    activeBundle = null;
    errorMessage = null;
  }

  @action
  bool applyABCBundle(
    BundleModel bundle,
    List<ProductModel> products,
  ) {
    if (bundle.fastProduct == null || bundle.slowProduct == null) {
      return false;
    }

    ProductModel? fast;
    ProductModel? slow;

    try {
      fast = products.firstWhere(
        (p) => p.productName == bundle.fastProduct!.productName,
      );
    } catch (_) {}

    try {
      slow = products.firstWhere(
        (p) => p.productName == bundle.slowProduct!.productName,
      );
    } catch (_) {}

    if (fast == null || slow == null) return false;

    final cartFastIndex = cart.indexWhere(
      (i) => i.productId == fast!.productId,
    );

    final cartSlowIndex = cart.indexWhere(
      (i) => i.productId == slow!.productId,
    );

    final currentFastQty =
        cartFastIndex > -1 ? cart[cartFastIndex].quantity : 0;

    final currentSlowQty =
        cartSlowIndex > -1 ? cart[cartSlowIndex].quantity : 0;

    if (currentFastQty + 1 > fast.stockQuantity ||
        currentSlowQty + 1 > slow.stockQuantity) {
      errorMessage =
          'Stok salah satu atau kedua produk paket promo sudah tidak mencukupi.';
      return false;
    }

    activeBundle = bundle;

    addToCart(fast);
    addToCart(slow);

    discountAmount += bundle.discountAmount;

    return true;
  }

  @action
  Future<Map<String, dynamic>?> checkout({
    required int paymentMethodId,
    required double paidAmount,
  }) async {
    isSubmitting = true;
    errorMessage = null;

    try {
      final Map<String, dynamic>? res = await remoteDataSource.checkout(
        paymentMethodId: paymentMethodId,
        paidAmount: paidAmount,
        discountAmount: discountAmount,
        items: cart.toList(),
      );

      // Periksa apakah response null
      if (res == null) {
        errorMessage = 'Checkout gagal: respons server kosong.';
        return null;
      }

      final data = res['data'];

      clearCart();

      if (data is Map<String, dynamic>) {
        return data;
      }

      return res;
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');

      return null;
    } finally {
      isSubmitting = false;
    }
  }
}
