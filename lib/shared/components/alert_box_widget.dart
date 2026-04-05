import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

enum DialogType { success, error, warning, info, custom }

class AppAlertDialog extends StatelessWidget {
  // Required
  final String title;
  final String message;

  // Optional / Customizable
  final DialogType type;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? customIcon;
  final Color? iconColor;
  final Color? confirmButtonColor;
  final bool barrierDismissible;
  final bool showCancelButton;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final String? imagePath;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = DialogType.info,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.customIcon,
    this.iconColor,
    this.confirmButtonColor,
    this.barrierDismissible = true,
    this.showCancelButton = false,
    this.titleStyle,
    this.messageStyle,
    this.imagePath,
  });

  // ── Convenience static method to show dialog ──
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    DialogType type = DialogType.info,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    IconData? customIcon,
    String? imagePath,
    Color? iconColor,
    Color? confirmButtonColor,
    bool barrierDismissible = true,
    bool showCancelButton = false,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AppAlertDialog(
        title: title,
        message: message,
        type: type,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        imagePath: imagePath,
        customIcon: customIcon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
        barrierDismissible: barrierDismissible,
        showCancelButton: showCancelButton,
        titleStyle: titleStyle,
        messageStyle: messageStyle,
      ),
    );
  }

  Color _getDefaultIconColor() {
    switch (type) {
      case DialogType.success:
        return const Color(0xFF34C759); // green
      case DialogType.error:
        return AppColors.primary;
      case DialogType.warning:
        return const Color(0xFFFF9500); // orange
      case DialogType.info:
      case DialogType.custom:
        return AppColors.blackColor;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_outline_rounded;
      case DialogType.error:
        return Icons.error_outline_rounded;
      case DialogType.warning:
        return Icons.warning_amber_rounded;
      case DialogType.info:
        return Icons.info_outline_rounded;
      case DialogType.custom:
        return customIcon ?? Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? _getDefaultIconColor();
    final effectiveConfirmColor = confirmButtonColor ?? AppColors.blackColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imagePath != null)
              SvgPicture.asset("$imagePath", height: 150)
            else ...[
              Icon(
                customIcon ?? _getDefaultIcon(),
                size: 64,
                color: effectiveIconColor,
              ),
            ], // Title
            14.0.height,
            Text(
              title,
              style:
                  titleStyle ??
                  AppFonts.themeText(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            8.0.height,
            Text(
              message,
              style:
                  messageStyle ??
                  context.appFonts.mediumBlack16.copyWith(
                    height: 1.4,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel Button (shown only when requested)
                if (showCancelButton) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        GoRouter.of(context).pop(false);
                        onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        cancelText ?? "Cancel",
                        style: context.appFonts.mediumBlack16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Confirm / Action Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveConfirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      confirmText ?? "OK",
                      style: AppFonts.mediumWhite16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/*

// Success
AppAlertDialog.show(
  context: context,
  type: DialogType.success,
  title: "Payment Successful",
  message: "Your booking has been confirmed!\nEnjoy your trip!",
  confirmText: "Great!",
);

// Error
AppAlertDialog.show(
  context: context,
  type: DialogType.error,
  title: "Something went wrong",
  message: "We couldn't process your request.\nPlease try again later.",
  confirmText: "Try Again",
);

// Warning with both buttons
AppAlertDialog.show(
  context: context,
  type: DialogType.warning,
  title: "Unsaved Changes",
  message: "You have unsaved changes.\nDo you want to leave without saving?",
  confirmText: "Leave",
  cancelText: "Stay",
  showCancelButton: true,
  onConfirm: () => Navigator.pop(context),
  onCancel: () {},
);

// Custom icon & color
AppAlertDialog.show(
  context: context,
  type: DialogType.custom,
  customIcon: Icons.celebration_rounded,
  iconColor: Colors.purple,
  title: "Welcome Back!",
  message: "You've successfully logged in.",
  confirmButtonColor: Colors.purple,
);

*/
