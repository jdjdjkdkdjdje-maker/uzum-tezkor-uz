import '../models/cart_item.dart';
import '../models/order.dart';
import '../network/api_client.dart';

class PlaceOrderResult {
  final OrderModel order;
  final String? paymentUrl;

  PlaceOrderResult({required this.order, this.paymentUrl});
}

class OrderRepository {
  final _client = ApiClient.instance;

  Future<PlaceOrderResult> placeOrder({
    required String restaurantId,
    String? addressId,
    required String orderType,
    required List<CartItem> items,
    String? promoCode,
    double? bonusToUse,
    required String paymentMethod,
    String? scheduledAt,
    String? customerComment,
  }) {
    return _client.post<PlaceOrderResult>(
      '/orders',
      data: {
        'restaurantId': restaurantId,
        if (addressId != null) 'addressId': addressId,
        'orderType': orderType,
        'items': items
            .map((item) => {
                  'productId': item.product.id,
                  if (item.variant != null) 'productVariantId': item.variant!.id,
                  'quantity': item.quantity,
                  if (item.addons.isNotEmpty)
                    'addons': item.addons
                        .map((a) => {'productAddonId': a.addon.id, 'quantity': a.quantity})
                        .toList(),
                  if (item.comment != null) 'comment': item.comment,
                })
            .toList(),
        if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
        if (bonusToUse != null && bonusToUse > 0) 'bonusToUse': bonusToUse,
        'paymentMethod': paymentMethod,
        if (scheduledAt != null) 'scheduledAt': scheduledAt,
        if (customerComment != null) 'customerComment': customerComment,
      },
      parse: (data) {
        // Order yaratish javobi to'g'ridan-to'g'ri Order obyekti;
        // to'lov linki alohida /payments/initiate javobida keladi (agar kerak bo'lsa).
        return PlaceOrderResult(order: OrderModel.fromJson(data));
      },
    );
  }

  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 20}) {
    return _client.get<List<OrderModel>>(
      '/orders/my',
      query: {'page': page, 'limit': limit},
      parse: (data) => (data['items'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<OrderModel> getOrder(String id) {
    return _client.get<OrderModel>('/orders/$id', parse: (data) => OrderModel.fromJson(data));
  }

  Future<void> cancelOrder(String id, {String? reason}) {
    return _client.patch<void>(
      '/orders/$id/status',
      data: {'status': 'cancelled_by_customer', if (reason != null) 'reason': reason},
      parse: (_) {},
    );
  }
}
