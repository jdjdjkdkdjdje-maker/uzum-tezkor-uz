import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/cart_item.dart';
import '../../../core/models/product.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../state/cart_provider.dart';
import '../../../widgets/quantity_stepper.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Restaurant restaurant;

  const ProductDetailScreen({super.key, required this.product, required this.restaurant});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductVariant? _selectedVariant;
  final Map<String, int> _addonQuantities = {};
  int _quantity = 1;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.firstWhere(
        (v) => v.isDefault,
        orElse: () => widget.product.variants.first,
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  double get _unitPrice {
    double price = widget.product.price;
    if (_selectedVariant != null) price += _selectedVariant!.extraPrice;
    for (final addon in widget.product.addons) {
      final qty = _addonQuantities[addon.id] ?? 0;
      price += addon.price * qty;
    }
    return price;
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();

    if (cart.wouldConflictWithRestaurant(widget.restaurant)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Savatchani tozalash kerak"),
          content: const Text(
            "Savatchangizda boshqa restorandan taomlar bor. Yangi restorandan buyurtma "
            "berish uchun avvalgi savatcha tozalanadi.",
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
            TextButton(
              onPressed: () {
                cart.clear();
                Navigator.pop(context);
                _confirmAdd();
              },
              child: const Text('Tozalash va davom etish'),
            ),
          ],
        ),
      );
      return;
    }
    _confirmAdd();
  }

  void _confirmAdd() {
    final cart = context.read<CartProvider>();
    final selectedAddons = widget.product.addons
        .where((a) => (_addonQuantities[a.id] ?? 0) > 0)
        .map((a) => CartAddonSelection(addon: a, quantity: _addonQuantities[a.id]!))
        .toList();

    cart.addItem(
      restaurant: widget.restaurant,
      product: widget.product,
      variant: _selectedVariant,
      addons: selectedAddons,
      quantity: _quantity,
      comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.cream,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.creamDeep),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.creamDeep,
                  child: const Icon(Icons.fastfood_rounded, size: 40, color: AppColors.textFaint),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(Formatters.price(_unitPrice), style: AppTextStyles.h1),
                      if (product.calories != null) ...[
                        const SizedBox(width: 12),
                        Text('${product.calories} kkal', style: AppTextStyles.caption),
                      ],
                    ],
                  ),
                  if (product.description != null) ...[
                    const SizedBox(height: 12),
                    Text(product.description!, style: AppTextStyles.body),
                  ],
                  if (product.ingredients != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Tarkibi: ${product.ingredients}",
                      style: AppTextStyles.caption,
                    ),
                  ],

                  if (product.variants.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Variantni tanlang', style: AppTextStyles.h2),
                    const SizedBox(height: 10),
                    ...product.variants.map(
                      (variant) => RadioListTile<ProductVariant>(
                        value: variant,
                        groupValue: _selectedVariant,
                        onChanged: (v) => setState(() => _selectedVariant = v),
                        activeColor: AppColors.tomato,
                        contentPadding: EdgeInsets.zero,
                        title: Text(variant.name, style: AppTextStyles.body),
                        secondary: variant.extraPrice > 0
                            ? Text('+${Formatters.price(variant.extraPrice)}', style: AppTextStyles.caption)
                            : null,
                      ),
                    ),
                  ],

                  if (product.addons.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text("Qo'shimchalar", style: AppTextStyles.h2),
                    const SizedBox(height: 10),
                    ...product.addons.map((addon) {
                      final qty = _addonQuantities[addon.id] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(addon.name, style: AppTextStyles.body),
                                  Text(Formatters.price(addon.price), style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            QuantityStepper(
                              quantity: qty,
                              onChanged: (v) => setState(() {
                                _addonQuantities[addon.id] = v.clamp(0, addon.maxQuantity);
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 20),
                  Text('Izoh (ixtiyoriy)', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: "Masalan: piyozsiz, achchiq bo'lmasin",
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              QuantityStepper(
                quantity: _quantity,
                min: 1,
                onChanged: (v) => setState(() => _quantity = v),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: product.isAvailable ? _addToCart : null,
                  child: Text(
                    "Savatchaga qo'shish · ${Formatters.price(_unitPrice * _quantity)}",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
