import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/constants/app_colors.dart';

class AppUtils {
  static void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[600],
      textColor: AppColors.whiteColor,
      fontSize: 16.0,
    );
  }

  static void _exitApp(BuildContext context) {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    } else {
      GoRouter.of(context).pop();
    }
  }

  static void handleBackPress({
    required DateTime? lastPressedAt,
    required void Function(DateTime) updateLastPressedAt,
    String title = 'Caution',
    String message = 'Press again to exit',
    required BuildContext context,
  }) {
    final now = DateTime.now();

    if (lastPressedAt == null ||
        now.difference(lastPressedAt) > const Duration(seconds: 2)) {
      updateLastPressedAt(now);
      AppUtils.showToast(message);
    } else {
      Fluttertoast.cancel();
      _exitApp(context);
    }
  }
}
