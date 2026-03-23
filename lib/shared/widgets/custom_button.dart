import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final double borderRadius;
  final double elevation;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final double? iconSpacing;
  final BorderSide? borderSide;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor = AppColors.primary,
    this.foregroundColor = Colors.white,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.borderRadius = 12,
    this.elevation = 0,
    this.textStyle,
    this.padding,
    this.icon,
    this.iconSpacing = 8,
    this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor:
              disabledBackgroundColor ?? backgroundColor.withValues(alpha: 0.6),
          disabledForegroundColor:
              disabledForegroundColor ?? foregroundColor.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: borderSide ?? BorderSide.none,
          ),
          elevation: elevation,
          padding: padding,
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                ),
              )
            : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  SizedBox(width: iconSpacing),
                  Text(
                    text,
                    style:
                        textStyle ??
                        AppFonts.mediumWhite16.copyWith(color: foregroundColor),
                  ),
                ],
              )
            : Text(
                text,
                style:
                    textStyle ??
                    AppFonts.mediumWhite16.copyWith(color: foregroundColor),
              ),
      ),
    );
  }
}
