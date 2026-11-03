class ABCProductItem {
  final String productName;
  final double sellPrice;
  final int stock;

  ABCProductItem({
    required this.productName,
    required this.sellPrice,
    required this.stock,
  });

  factory ABCProductItem.fromJson(Map<String, dynamic> json) {
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

    return ABCProductItem(
      productName: json['product_name']?.toString() ?? '',
      sellPrice: parseDouble(json['sell_price']),
      stock: parseInt(json['stock']),
    );
  }
}

class BundleModel {
  final ABCProductItem? fastProduct;
  final ABCProductItem? slowProduct;
  final double normalPrice;
  final String discountRate;
  final double discountAmount;
  final double promoPrice;
  final double estimatedProfit;

  BundleModel({
    this.fastProduct,
    this.slowProduct,
    required this.normalPrice,
    required this.discountRate,
    required this.discountAmount,
    required this.promoPrice,
    required this.estimatedProfit,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    return BundleModel(
      fastProduct: json['fast_product'] != null ? ABCProductItem.fromJson(json['fast_product']) : null,
      slowProduct: json['slow_product'] != null ? ABCProductItem.fromJson(json['slow_product']) : null,
      normalPrice: parseDouble(json['normal_price']),
      discountRate: json['discount_rate']?.toString() ?? '0%',
      discountAmount: parseDouble(json['discount_amount']),
      promoPrice: parseDouble(json['promo_price']),
      estimatedProfit: parseDouble(json['estimated_profit']),
    );
  }
}