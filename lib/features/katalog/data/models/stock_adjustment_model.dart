class StockAdjustmentModel {
  final int adjustmentId;
  final int productId;
  final int userId;
  final String adjustmentType;
  final int quantityChanged;
  final String reason;
  final String createdAt;
  final String? productName;
  final String? productSku;
  final String? userName;

  StockAdjustmentModel({
    required this.adjustmentId,
    required this.productId,
    required this.userId,
    required this.adjustmentType,
    required this.quantityChanged,
    required this.reason,
    required this.createdAt,
    this.productName,
    this.productSku,
    this.userName,
  });

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    // Relasi Product
    final productData = json['product'];
    String? pName, pSku;
    if (productData != null && productData is Map<String, dynamic>) {
      pName = productData['product_name']?.toString();
      pSku = productData['sku']?.toString();
    }

    // Relasi User
    final userData = json['user'];
    String? uName;
    if (userData != null && userData is Map<String, dynamic>) {
      uName = userData['name']?.toString();
    }

    return StockAdjustmentModel(
      adjustmentId: parseInt(json['adjustment_id'] ?? json['id']),
      productId: parseInt(json['product_id']),
      userId: parseInt(json['user_id']),
      adjustmentType: json['adjustment_type']?.toString() ?? 'IN',
      quantityChanged: parseInt(json['quantity_changed'] ?? json['quantity']),
      reason: json['reason']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      productName: pName,
      productSku: pSku,
      userName: uName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'adjustment_type': adjustmentType,
      'quantity': quantityChanged,
      'reason': reason,
    };
  }
}