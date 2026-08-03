class OrderItemModel {
  final String id;
  final String productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? comment;

  OrderItemModel({
    required this.id,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.comment,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: (json['product'] as Map<String, dynamic>?)?['name'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      comment: json['comment'] as String?,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String orderType;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double bonusUsed;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? restaurantName;
  final String? restaurantLogoUrl;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.orderType,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.bonusUsed,
    required this.totalAmount,
    required this.createdAt,
    this.deliveredAt,
    this.restaurantName,
    this.restaurantLogoUrl,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final restaurant = json['restaurant'] as Map<String, dynamic>?;
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String? ?? '',
      status: json['status'] as String,
      orderType: json['orderType'] as String? ?? 'delivery',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      bonusUsed: (json['bonusUsed'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt:
          json['deliveredAt'] != null ? DateTime.tryParse(json['deliveredAt'] as String) : null,
      restaurantName: restaurant?['name'] as String?,
      restaurantLogoUrl: restaurant?['logoUrl'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
