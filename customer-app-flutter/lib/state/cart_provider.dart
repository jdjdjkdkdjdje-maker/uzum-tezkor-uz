import 'package:flutter/foundation.dart';
import '../core/models/cart_item.dart';
import '../core/models/product.dart';
import '../core/models/restaurant.dart';

/// Savatcha faqat bitta restorandan buyurtma qilishni qo'llab-quvvatlaydi
/// (aksariyat yetkazib berish platformalari kabi).
class CartProvider extends ChangeNotifier {
  Restaurant? _restaurant;
  final List<CartItem> _items = [];

  Restaurant? get restaurant => _restaurant;
  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.totalPrice);

  double get deliveryFee => _restaurant?.deliveryFee ?? 0;
  double get total => subtotal + deliveryFee;

  bool get meetsMinimum =>
      _restaurant == null || subtotal >= _restaurant!.minOrderAmount;

  double get amountToMinimum =>
      _restaurant == null ? 0 : (_restaurant!.minOrderAmount - subtotal).clamp(0, double.infinity);

  /// Boshqa restorandan mahsulot qo'shishga urinilsa, avval savatchani tozalash kerakligini bildiradi
  bool wouldConflictWithRestaurant(Restaurant newRestaurant) {
    return _restaurant != null && _restaurant!.id != newRestaurant.id && _items.isNotEmpty;
  }

  void addItem({
    required Restaurant restaurant,
    required Product product,
    ProductVariant? variant,
    List<CartAddonSelection> addons = const [],
    int quantity = 1,
    String? comment,
  }) {
    if (_restaurant != null && _restaurant!.id != restaurant.id) {
      _items.clear();
    }
    _restaurant = restaurant;

    final id = _buildItemId(product.id, variant?.id, addons, comment);
    final existingIndex = _items.indexWhere((i) => i.id == id);

    if (existingIndex != -1) {
      _items[existingIndex] =
          _items[existingIndex].copyWith(quantity: _items[existingIndex].quantity + quantity);
    } else {
      _items.add(CartItem(
        id: id,
        product: product,
        variant: variant,
        addons: addons,
        quantity: quantity,
        comment: comment,
      ));
    }
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    if (_items.isEmpty) _restaurant = null;
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
    if (_items.isEmpty) _restaurant = null;
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _restaurant = null;
    notifyListeners();
  }

  String _buildItemId(
    String productId,
    String? variantId,
    List<CartAddonSelection> addons,
    String? comment,
  ) {
    final addonKey = (addons.map((a) => '${a.addon.id}x${a.quantity}').toList()..sort()).join(',');
    return '$productId|${variantId ?? ''}|$addonKey|${comment ?? ''}';
  }
}
