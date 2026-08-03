import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/address.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/repositories/address_repository.dart';
import '../../../core/repositories/order_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../state/cart_provider.dart';
import '../../orders/screens/order_tracking_screen.dart';

enum _PaymentMethod { click, payme, uzumBank, cash }

extension on _PaymentMethod {
  String get apiValue => switch (this) {
        _PaymentMethod.click => 'click',
        _PaymentMethod.payme => 'payme',
        _PaymentMethod.uzumBank => 'uzum_bank',
        _PaymentMethod.cash => 'cash',
      };

  String get label => switch (this) {
        _PaymentMethod.click => 'Click',
        _PaymentMethod.payme => 'Payme',
        _PaymentMethod.uzumBank => 'Uzum Bank',
        _PaymentMethod.cash => 'Naqd pul',
      };

  IconData get icon => switch (this) {
        _PaymentMethod.cash => Icons.payments_outlined,
        _ => Icons.credit_card_rounded,
      };
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressRepo = AddressRepository();
  final _orderRepo = OrderRepository();
  final _promoController = TextEditingController();
  final _commentController = TextEditingController();

  List<Address> _addresses = [];
  Address? _selectedAddress;
  _PaymentMethod _paymentMethod = _PaymentMethod.cash;
  bool _isLoadingAddresses = true;
  bool _isPlacingOrder = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddresses());
  }

  @override
  void dispose() {
    _promoController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    try {
      final addresses = await _addressRepo.findAll();
      if (!mounted) return;
      setState(() {
        _addresses = addresses;
        _selectedAddress = addresses.isNotEmpty
            ? addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)
            : null;
      });
    } catch (_) {
      // Manzil topilmasa, foydalanuvchi yangi manzil qo'sha oladi
    } finally {
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, yetkazib berish manzilini tanlang')),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
      _error = null;
    });

    try {
      final result = await _orderRepo.placeOrder(
        restaurantId: cart.restaurant!.id,
        addressId: _selectedAddress!.id,
        orderType: 'delivery',
        items: cart.items,
        promoCode: _promoController.text.trim(),
        paymentMethod: _paymentMethod.apiValue,
        customerComment:
            _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
      );

      if (!mounted) return;
      cart.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: result.order.id)),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Buyurtmani rasmiylashtirish')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Yetkazib berish manzili', style: AppTextStyles.h2),
          const SizedBox(height: 10),
          if (_isLoadingAddresses)
            const Center(child: CircularProgressIndicator())
          else if (_addresses.isEmpty)
            OutlinedButton.icon(
              onPressed: () {
                // Amaliy loyihada bu yerda xarita orqali manzil tanlash ekrani ochiladi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Manzil qo'shish ekrani (xarita) ulanishi kerak")),
                );
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text("Manzil qo'shish"),
            )
          else
            ..._addresses.map(
              (address) => _AddressTile(
                address: address,
                selected: _selectedAddress?.id == address.id,
                onTap: () => setState(() => _selectedAddress = address),
              ),
            ),

          const SizedBox(height: 24),
          Text("To'lov usuli", style: AppTextStyles.h2),
          const SizedBox(height: 10),
          ..._PaymentMethod.values.map(
            (method) => RadioListTile<_PaymentMethod>(
              value: method,
              groupValue: _paymentMethod,
              onChanged: (v) => setState(() => _paymentMethod = v!),
              activeColor: AppColors.tomato,
              contentPadding: EdgeInsets.zero,
              secondary: Icon(method.icon, color: AppColors.textMuted),
              title: Text(method.label, style: AppTextStyles.body),
            ),
          ),

          const SizedBox(height: 24),
          Text('Promo kod', style: AppTextStyles.h2),
          const SizedBox(height: 10),
          TextField(
            controller: _promoController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(hintText: 'Promo kodni kiriting'),
          ),

          const SizedBox(height: 24),
          Text('Kuryerga izoh', style: AppTextStyles.h2),
          const SizedBox(height: 10),
          TextField(
            controller: _commentController,
            maxLines: 2,
            decoration: const InputDecoration(hintText: 'Masalan: domofon ishlamaydi'),
          ),

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: [
                _SummaryRow(label: 'Mahsulotlar', value: Formatters.price(cart.subtotal)),
                _SummaryRow(
                  label: 'Yetkazib berish',
                  value: cart.deliveryFee == 0 ? 'Bepul' : Formatters.price(cart.deliveryFee),
                ),
                const Divider(height: 20),
                _SummaryRow(label: 'Jami', value: Formatters.price(cart.total), isTotal: true),
              ],
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            child: _isPlacingOrder
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text('Buyurtmani tasdiqlash · ${Formatters.price(cart.total)}'),
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;

  const _AddressTile({required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.tomato : AppColors.line, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? AppColors.tomato : AppColors.textFaint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(address.title ?? 'Manzil', style: AppTextStyles.bodyMedium),
                  Text(address.addressLine, style: AppTextStyles.caption),
                ],
              ),
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
