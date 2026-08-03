import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/models/banner.dart';
import '../../../core/models/product.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/repositories/banner_repository.dart';
import '../../../core/repositories/category_repository.dart';
import '../../../core/repositories/restaurant_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../state/location_provider.dart';
import '../../../widgets/cart_bar.dart';
import '../../../widgets/error_retry_view.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_chip.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerRepo = BannerRepository();
  final _categoryRepo = CategoryRepository();
  final _restaurantRepo = RestaurantRepository();
  final _searchController = TextEditingController();

  List<BannerModel> _banners = [];
  List<ProductCategory> _categories = [];
  List<Restaurant> _restaurants = [];
  String? _selectedCategoryId;
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
      final location = context.read<LocationProvider>();
      await location.loadCurrentLocation();

      final results = await Future.wait([
        _bannerRepo.findActive(),
        _categoryRepo.findAll(),
        _restaurantRepo.findAll(
          latitude: location.effectiveLatitude,
          longitude: location.effectiveLongitude,
          search: _searchController.text,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _banners = results[0] as List<BannerModel>;
        _categories = results[1] as List<ProductCategory>;
        _restaurants = results[2] as List<Restaurant>;
      });
    } catch (e) {
      if (mounted) setState(() => _error = "Ma'lumotlarni yuklab bo'lmadi");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Restaurant> get _filteredRestaurants {
    if (_selectedCategoryId == null) return _restaurants;
    // Eslatma: to'liq versiyada restoran-kategoriya bog'lanishi backend orqali filtrlanadi.
    return _restaurants;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _error != null
              ? ErrorRetryView(message: _error!, onRetry: _load)
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildSearchBar()),
                    if (_isLoading)
                      SliverToBoxAdapter(child: _buildLoadingPlaceholder())
                    else ...[
                      SliverToBoxAdapter(child: const SizedBox(height: 16)),
                      SliverToBoxAdapter(child: BannerCarousel(banners: _banners)),
                      SliverToBoxAdapter(child: _buildCategories()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                          child: Text('Restoranlar', style: AppTextStyles.h1),
                        ),
                      ),
                      if (_filteredRestaurants.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'Bu hududda restoranlar topilmadi',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                RestaurantCard(restaurant: _filteredRestaurants[index]),
                            childCount: _filteredRestaurants.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 90)),
                    ],
                  ],
                ),
        ),
      ),
      bottomSheet: const CartBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: AppColors.tomato, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Joriy manzil',
              style: AppTextStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(Icons.notifications_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _load(),
        decoration: InputDecoration(
          hintText: 'Restoran yoki taom qidirish',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppColors.textMuted),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryChip(
            category: category,
            selected: _selectedCategoryId == category.id,
            onTap: () => setState(() {
              _selectedCategoryId = _selectedCategoryId == category.id ? null : category.id;
            }),
          );
        },
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.creamDeep,
      highlightColor: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
