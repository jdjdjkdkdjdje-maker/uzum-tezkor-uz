import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/models/product.dart';
import '../../../core/models/restaurant.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../product/screens/product_detail_screen.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final Restaurant restaurant;

  const ProductListTile({super.key, required this.product, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: product.isAvailable
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product, restaurant: restaurant),
                ),
              )
          : null,
      child: Opacity(
        opacity: product.isAvailable ? 1 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppTextStyles.h2),
                    if (product.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.description!,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(Formatters.price(product.price), style: AppTextStyles.price),
                        if (product.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            Formatters.price(product.oldPrice!),
                            style: AppTextStyles.caption.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        if (!product.isAvailable) ...[
                          const SizedBox(width: 8),
                          Text('Tugagan', style: AppTextStyles.small.copyWith(color: AppColors.danger)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(width: 84, height: 84, color: AppColors.creamDeep),
                  errorWidget: (context, url, error) => Container(
                    width: 84,
                    height: 84,
                    color: AppColors.creamDeep,
                    child: const Icon(Icons.fastfood_rounded, color: AppColors.textFaint),
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
