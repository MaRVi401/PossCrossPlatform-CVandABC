class CartItemModel {
  final int productId;
  final String productName;
  final double sellPrice;
  final int stockQuantity;
  int quantity;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.sellPrice,
    required this.stockQuantity,
    this.quantity = 1,
  });

  double get subtotal => sellPrice * quantity;

  Map<String, dynamic> toTransactionJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}