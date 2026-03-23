import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:account_ledger/core/constants/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.divider,
      child: child,
    );
  }
}
