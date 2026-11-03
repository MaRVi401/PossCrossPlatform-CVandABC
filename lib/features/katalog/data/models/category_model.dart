class CategoryModel {
  final int categoryId;
  final String categoryName;
  final String? description;
  final int productsCount;

  CategoryModel({
    required this.categoryId,
    required this.categoryName,
    this.description,
    this.productsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] ?? json['id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      description: json['description'],
      productsCount: json['products_count'] ?? json['productsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'products_count': productsCount,
    };
  }
}