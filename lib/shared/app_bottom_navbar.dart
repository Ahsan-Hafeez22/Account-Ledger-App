import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  SystemUiOverlayStyle _getStatusBarStyle() {
    final isLightTheme = currentIndex == 3; // Settings tab

    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isLightTheme
          ? Brightness.dark
          : Brightness.light,
      statusBarBrightness: isLightTheme ? Brightness.light : Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _getStatusBarStyle(),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabChanged,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.blackColor,
        unselectedItemColor: AppColors.disableColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_outlined),
            activeIcon: Icon(Icons.swap_horiz_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
          ),
        ],
      ),
    );
  }
}
