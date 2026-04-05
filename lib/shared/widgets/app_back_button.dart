import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback onPress;

  const AppBackButton({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.only(left: 16.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back,
            size: 20.sp, // 👈 Responsive icon size
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
