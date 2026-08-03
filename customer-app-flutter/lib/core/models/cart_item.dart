import 'package:equatable/equatable.dart';
import 'product.dart';

class CartAddonSelection extends Equatable {
  final ProductAddon addon;
  final int quantity;

  const CartAddonSelection({required this.addon, required this.quantity});

  double get total => addon.price * quantity;

  @override
  List<Object?> get props => [addon.id, quantity];
}

class CartItem extends Equatable {
  final String id; // mahalliy unikal identifikator
  final Product product;
  final ProductVariant? variant;
  final List<CartAddonSelection> addons;
  final int quantity;
  final String? comment;

  const CartItem({
    required this.id,
    required this.product,
    this.variant,
    this.addons = const [],
    required this.quantity,
    this.comment,
  });

  double get unitPrice {
    double price = product.price;
    if (variant != null) price += variant!.extraPrice;
    price += addons.fold(0.0, (sum, a) => sum + a.total);
    return price;
  }

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      product: product,
      variant: variant,
      addons: addons,
      quantity: quantity ?? this.quantity,
      comment: comment,
    );
  }

  @override
  List<Object?> get props => [id];
}
