import 'package:mobx/mobx.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'pos_store.g.dart';

// ignore: library_private_types_in_public_api
class POSStore = _POSStore with _$POSStore;

abstract class _POSStore with Store {
  final GetProductsUseCase getProductsUseCase;

  _POSStore({required this.getProductsUseCase});

  @observable
  ObservableList<ProductEntity> products = ObservableList<ProductEntity>();

  @observable
  ObservableMap<ProductEntity, int> cart = ObservableMap<ProductEntity, int>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  double get totalPrice {
    double total = 0;
    cart.forEach((product, qty) {
      total += product.price * qty;
    });
    return total;
  }

  @action
  Future<void> loadProducts() async {
    isLoading = true;
    errorMessage = null;

    final result = await getProductsUseCase();
    result.fold(
      (failure) => errorMessage = failure.message,
      (data) => products = ObservableList.of(data),
    );

    isLoading = false;
  }

  @action
  void addToCart(ProductEntity product) {
    if (cart.containsKey(product)) {
      cart[product] = cart[product]! + 1;
    } else {
      cart[product] = 1;
    }
    cart = ObservableMap.of(cart);
  }

  @action
  void removeFromCart(ProductEntity product) {
    if (cart.containsKey(product)) {
      if (cart[product]! > 1) {
        cart[product] = cart[product]! - 1;
      } else {
        cart.remove(product);
      }
      cart = ObservableMap.of(cart);
    }
  }

  @action
  void clearCart() {
    cart.clear();
  }
}