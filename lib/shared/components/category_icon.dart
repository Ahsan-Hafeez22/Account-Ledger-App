import 'package:flutter/material.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';

class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final mapped = _mapCategory(category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: mapped.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(mapped.icon, color: mapped.color, size: size * 0.5),
    );
  }

  static _CategoryData _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case 'housing':
        return _CategoryData(Icons.home_rounded, AppColors.housing);
      case 'food':
        return _CategoryData(Icons.restaurant_rounded, AppColors.food);
      case 'transport':
        return _CategoryData(Icons.directions_car_rounded, AppColors.transport);
      case 'entertainment':
        return _CategoryData(Icons.movie_rounded, AppColors.entertainment);
      case 'health':
        return _CategoryData(Icons.favorite_rounded, AppColors.health);
      default:
        return _CategoryData(Icons.category_rounded, AppColors.other);
    }
  }
}

class _CategoryData {
  final IconData icon;
  final Color color;

  const _CategoryData(this.icon, this.color);
}
