class ProductVariant {
  final String id;
  final String name;
  final double extraPrice;
  final bool isDefault;

  ProductVariant({
    required this.id,
    required this.name,
    required this.extraPrice,
    required this.isDefault,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String,
      name: json['name'] as String,
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

class ProductAddon {
  final String id;
  final String name;
  final double price;
  final int maxQuantity;

  ProductAddon({
    required this.id,
    required this.name,
    required this.price,
    required this.maxQuantity,
  });

  factory ProductAddon.fromJson(Map<String, dynamic> json) {
    return ProductAddon(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      maxQuantity: json['maxQuantity'] as int? ?? 1,
    );
  }
}

class Product {
  final String id;
  final String restaurantId;
  final String? categoryId;
  final String name;
  final String? description;
  final double price;
  final double? oldPrice;
  final double discountPercent;
  final int? calories;
  final String? ingredients;
  final bool isAvailable;
  final double rating;
  final int reviewsCount;
  final int ordersCount;
  final List<String> imageUrls;
  final List<ProductVariant> variants;
  final List<ProductAddon> addons;

  Product({
    required this.id,
    required this.restaurantId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.oldPrice,
    required this.discountPercent,
    this.calories,
    this.ingredients,
    required this.isAvailable,
    required this.rating,
    required this.reviewsCount,
    required this.ordersCount,
    this.imageUrls = const [],
    this.variants = const [],
    this.addons = const [],
  });

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String? ?? '',
      categoryId: json['categoryId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0,
      calories: json['calories'] as int?,
      ingredients: json['ingredients'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: json['reviewsCount'] as int? ?? 0,
      ordersCount: json['ordersCount'] as int? ?? 0,
      imageUrls: (json['images'] as List<dynamic>? ?? [])
          .map((e) => (e as Map<String, dynamic>)['imageUrl'] as String)
          .toList(),
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      addons: (json['addons'] as List<dynamic>? ?? [])
          .map((e) => ProductAddon.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductCategory {
  final String id;
  final String? restaurantId;
  final String name;
  final String? iconUrl;
  final int sortOrder;

  ProductCategory({
    required this.id,
    this.restaurantId,
    required this.name,
    this.iconUrl,
    required this.sortOrder,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      restaurantId: json['restaurantId'] as String?,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }
}
