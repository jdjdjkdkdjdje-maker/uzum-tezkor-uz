import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/repositories/category_repository.dart';
import '../../../core/repositories/product_repository.dart';
import '../../../core/repositories/restaurant_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/cart_bar.dart';
import '../../../widgets/error_retry_view.dart';
import '../widgets/product_list_tile.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _restaurantRepo = RestaurantRepository();
  final _productRepo = ProductRepository();
  final _categoryRepo = CategoryRepository();

  Restaurant? _restaurant;
  List<Product> _products = [];
  List<ProductCategory> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _restaurantRepo.findOne(widget.restaurantId),
        _productRepo.findByRestaurant(widget.restaurantId),
        _categoryRepo.findAll(restaurantId: widget.restaurantId),
      ]);
      if (!mounted) return;
      setState(() {
        _restaurant = results[0] as Restaurant;
        _products = results[1] as List<Product>;
        _categories = results[2] as List<ProductCategory>;
      });
    } catch (_) {
      if (mounted) setState(() => _error = "Restoran ma'lumotlarini yuklab bo'lmadi");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _restaurant == null) {
      return Scaffold(body: ErrorRetryView(message: _error ?? 'Xatolik', onRetry: _load));
    }

    final restaurant = _restaurant!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.cream,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: restaurant.coverImageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.creamDeep),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.creamDeep,
                  child: const Icon(Icons.restaurant_rounded, size: 40, color: AppColors.textFaint),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: AppTextStyles.display),
                  const SizedBox(height: 6),
                  if (restaurant.description != null)
                    Text(restaurant.description!, style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.star_rounded, label: restaurant.rating.toStringAsFixed(1), color: AppColors.star),
                      _InfoChip(icon: Icons.access_time_rounded, label: '${restaurant.avgPreparationMin} daq'),
                      _InfoChip(
                        icon: Icons.delivery_dining_rounded,
                        label: restaurant.deliveryFee == 0 ? 'Bepul' : '${restaurant.deliveryFee.toStringAsFixed(0)} so\'m',
                      ),
                      _InfoChip(
                        icon: restaurant.isOpenNow ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        label: restaurant.isOpenNow ? 'Ochiq' : 'Yopiq',
                        color: restaurant.isOpenNow ? AppColors.success : AppColors.danger,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider(height: 24)),
          if (_products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('Bu restoranda hozircha taomlar yo\'q')),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    ProductListTile(product: _products[index], restaurant: restaurant),
                childCount: _products.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomSheet: const CartBar(),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
