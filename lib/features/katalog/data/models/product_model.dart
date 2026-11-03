class ProductModel {
  final int productId;
  final int categoryId;
  final String sku;
  final String productName;
  final String? imageUrl;
  final double buyPrice;
  final double sellPrice;
  final int stockQuantity;
  final int minStockAlert;
  final String? categoryName;

  ProductModel({
    required this.productId,
    required this.categoryId,
    required this.sku,
    required this.productName,
    this.imageUrl,
    required this.buyPrice,
    required this.sellPrice,
    required this.stockQuantity,
    required this.minStockAlert,
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['category'];
    String? resolvedCategoryName;
    if (categoryData != null && categoryData is Map<String, dynamic>) {
      resolvedCategoryName = categoryData['category_name'];
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return ProductModel(
      productId: parseInt(json['product_id'] ?? json['id']),
      categoryId: parseInt(json['category_id']),
      sku: json['sku']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      buyPrice: parseDouble(json['buy_price']),
      sellPrice: parseDouble(json['sell_price']),
      stockQuantity: parseInt(json['stock_quantity']),
      minStockAlert: parseInt(json['min_stock_alert']),
      categoryName: resolvedCategoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'category_id': categoryId,
      'sku': sku,
      'product_name': productName,
      'image_url': imageUrl,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'stock_quantity': stockQuantity,
      'min_stock_alert': minStockAlert,
    };
  }
}