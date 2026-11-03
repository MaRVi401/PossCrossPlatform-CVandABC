class BundleItemModel {
  final String productName;
  final int stock;
  final double price;
  final String status;

  BundleItemModel({
    required this.productName,
    required this.stock,
    required this.price,
    required this.status,
  });

  factory BundleItemModel.fromJson(Map<String, dynamic> json) {
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

    return BundleItemModel(
      productName: json['product_name']?.toString() ?? '',
      stock: parseInt(json['stok'] ?? json['stock']),
      price: parseDouble(json['price'] ?? json['harga']),
      status: json['status']?.toString() ?? 'FAST MOVING',
    );
  }
}

class BundleModel {
  final String bundleName;
  final List<BundleItemModel> items;
  final double normalTotalPrice;
  final double discountAmount;
  final double promoPrice;
  final double estimatedMargin;

  BundleModel({
    required this.bundleName,
    required this.items,
    required this.normalTotalPrice,
    required this.discountAmount,
    required this.promoPrice,
    required this.estimatedMargin,
  });

  factory BundleModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is double) return val;
      if (val is int) return val.toDouble();
      return double.tryParse(val.toString()) ?? 0.0;
    }

    var rawItems = json['items'] ?? json['products'] ?? [];
    List<BundleItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems.map((i) => BundleItemModel.fromJson(i)).toList();
    }

    return BundleModel(
      bundleName: json['bundle_name']?.toString() ?? 'Hasil Rekomendasi Artificial Bee Colony',
      items: parsedItems,
      normalTotalPrice: parseDouble(json['normal_total_price'] ?? json['harga_normal_total']),
      discountAmount: parseDouble(json['discount_amount'] ?? json['diskon_lebah']),
      promoPrice: parseDouble(json['promo_price'] ?? json['harga_paket_promo']),
      estimatedMargin: parseDouble(json['estimated_margin'] ?? json['estimasi_margin_profit']),
    );
  }
}