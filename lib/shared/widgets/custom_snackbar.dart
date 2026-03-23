import 'package:flutter/material.dart';
import 'package:account_ledger/core/constants/app_colors.dart';

enum SnackBarType { success, error, warning, info }

enum SnackBarPosition { top, bottom }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    SnackBarPosition position = SnackBarPosition.top,
  }) {
    if (position == SnackBarPosition.top) {
      _showTopOverlay(
        context,
        message: message,
        type: type,
        duration: duration,
      );
    } else {
      _showBottomSnackBar(
        context,
        message: message,
        type: type,
        duration: duration,
      );
    }
  }

  static void _showBottomSnackBar(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    required Duration duration,
  }) {
    final config = _getConfig(type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _buildContent(config, message),
        backgroundColor: config.color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        elevation: 6,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  static void _showTopOverlay(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    required Duration duration,
  }) {
    final config = _getConfig(type);
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: config.color,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildContent(config, message),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  static Widget _buildContent(_SnackBarConfig config, String message) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(config.icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static _SnackBarConfig _getConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          color: const Color(0xFF4CAF50),
          icon: Icons.check_circle_rounded,
          title: 'Success',
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          color: const Color(0xFFEF5350),
          icon: Icons.error_rounded,
          title: 'Error',
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          color: const Color(0xFFFF9800),
          icon: Icons.warning_rounded,
          title: 'Warning',
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          color: AppColors.primary,
          icon: Icons.info_rounded,
          title: 'Info',
        );
    }
  }

  //   static EdgeInsets _getMarginConfig(
  //   BuildContext context,
  //   SnackBarPosition position,
  // ) {
  //   switch (position) {
  //     case SnackBarPosition.top:
  //       return EdgeInsets.only(
  //         left: 16,
  //         right: 16,
  //         top: 16,
  //         bottom: MediaQuery.of(context).size.height - 150,
  //       );
  //     case SnackBarPosition.bottom:
  //       return const EdgeInsets.fromLTRB(16, 0, 16, 16);
  //   }
  // }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;
  final String title;

  _SnackBarConfig({
    required this.color,
    required this.icon,
    required this.title,
  });
}

// Usage Examples:
/*

// Success message (bottom - default)
CustomSnackBar.show(
  context,
  message: 'Appointment booked successfully!',
  type: SnackBarType.success,
);

// Error message at top
CustomSnackBar.show(
  context,
  message: 'Failed to process your request',
  type: SnackBarType.error,
  position: SnackBarPosition.top,
);

// Warning message at bottom
CustomSnackBar.show(
  context,
  message: 'Please fill all required fields',
  type: SnackBarType.warning,
  position: SnackBarPosition.bottom,
);

// Info message at top with custom duration
CustomSnackBar.show(
  context,
  message: 'Your session will expire in 5 minutes',
  type: SnackBarType.info,
  position: SnackBarPosition.top,
  duration: Duration(seconds: 5),
);

*/
