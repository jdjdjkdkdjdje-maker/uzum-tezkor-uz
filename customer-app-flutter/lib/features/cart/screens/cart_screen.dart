import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../state/cart_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/quantity_stepper.dart';
import '../../checkout/screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Savatcha')),
      body: cart.isEmpty
          ? const EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: "Savatchangiz bo'sh",
              subtitle: "Taomlarni ko'rish uchun restoranlar ro'yxatiga qayting",
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 18, color: AppColors.tomato),
                      const SizedBox(width: 8),
                      Text(cart.restaurant?.name ?? '', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) => _CartItemTile(item: cart.items[index]),
                  ),
                ),
                _CartSummary(cart: cart),
              ],
            ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: AppTextStyles.bodyMedium),
                if (item.variant != null)
                  Text(item.variant!.name, style: AppTextStyles.caption),
                if (item.addons.isNotEmpty)
                  Text(
                    item.addons.map((a) => '${a.addon.name} x${a.quantity}').join(', '),
                    style: AppTextStyles.caption,
                  ),
                if (item.comment != null)
                  Text('"${item.comment}"', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Text(Formatters.price(item.totalPrice), style: AppTextStyles.price),
              ],
            ),
          ),
          const SizedBox(width: 8),
          QuantityStepper(
            quantity: item.quantity,
            onChanged: (v) => cart.updateQuantity(item.id, v),
          ),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartProvider cart;

  const _CartSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow(label: 'Mahsulotlar', value: Formatters.price(cart.subtotal)),
            _SummaryRow(
              label: 'Yetkazib berish',
              value: cart.deliveryFee == 0 ? 'Bepul' : Formatters.price(cart.deliveryFee),
            ),
            const Divider(height: 20),
            _SummaryRow(label: 'Jami', value: Formatters.price(cart.total), isTotal: true),
            const SizedBox(height: 16),
            if (!cart.meetsMinimum)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Minimal buyurtma uchun yana ${Formatters.price(cart.amountToMinimum)} kerak',
                  style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: cart.meetsMinimum
                  ? () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                      )
                  : null,
              child: const Text('Buyurtma berish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final style = isTotal ? AppTextStyles.h2 : AppTextStyles.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style.copyWith(color: isTotal ? AppColors.charcoal : AppColors.textMuted)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
