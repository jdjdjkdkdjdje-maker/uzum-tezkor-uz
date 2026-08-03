import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../restaurant/screens/restaurant_detail_screen.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final isOpen = restaurant.isOpenNow;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: CachedNetworkImage(
                    imageUrl: restaurant.coverImageUrl ?? '',
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(height: 130, color: AppColors.creamDeep),
                    errorWidget: (context, url, error) => Container(
                      height: 130,
                      color: AppColors.creamDeep,
                      child: const Icon(Icons.restaurant_rounded, color: AppColors.textFaint, size: 32),
                    ),
                  ),
                ),
                if (!isOpen)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Yopiq',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                if (restaurant.isFeatured && isOpen)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.tomato,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tavsiya etiladi',
                        style: AppTextStyles.small.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 15, color: AppColors.star),
                      const SizedBox(width: 3),
                      Text('${restaurant.rating.toStringAsFixed(1)}', style: AppTextStyles.caption),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Text('${restaurant.avgPreparationMin} daq', style: AppTextStyles.caption),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          restaurant.deliveryFee == 0
                              ? 'Bepul yetkazish'
                              : Formatters.price(restaurant.deliveryFee),
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
