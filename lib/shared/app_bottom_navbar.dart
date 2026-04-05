import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/features/account/presentation/pages/account_page.dart';
import 'package:account_ledger/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:account_ledger/features/setting/presentation/pages/setting_page.dart';
import 'package:account_ledger/features/transaction/presentation/pages/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class BottomNavScaffold extends StatefulWidget {
  final int initialIndex;

  const BottomNavScaffold({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  late final PersistentTabController _controller;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: widget.initialIndex);
    _screens = const [
      DashboardPage(),
      TransactionPage(),
      AccountPage(),
      SettingPage(),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateStatusBarStyle(_controller.index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusBarStyle(_controller.index);
    });
  }

  void _updateStatusBarStyle(int index) {
    if (!mounted) return;
  }

  List<PersistentBottomNavBarItem> _items(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final navTheme = Theme.of(context).bottomNavigationBarTheme;
    final active =
        navTheme.selectedItemColor ?? scheme.primary;
    final inactive =
        navTheme.unselectedItemColor ??
        AppColors.secondaryTextColor(Theme.of(context).brightness);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_rounded),
        inactiveIcon: const Icon(Icons.home_outlined),
        title: 'Home',
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.swap_horiz_rounded),
        inactiveIcon: const Icon(Icons.swap_horiz_outlined),
        title: 'Transactions',
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.account_balance_wallet_rounded),
        inactiveIcon: const Icon(Icons.account_balance_wallet_outlined),
        title: 'Accounts',
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings_rounded),
        inactiveIcon: const Icon(Icons.settings_outlined),
        title: 'Settings',
        activeColorPrimary: active,
        inactiveColorPrimary: inactive,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatusBarStyle(_controller.index);
    });

    final navBarBackground =
        Theme.of(context).bottomNavigationBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.scaffoldBg,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens,
        backgroundColor: navBarBackground,
        items: _items(context),
        hideNavigationBarWhenKeyboardShows: true,
        navBarHeight: 60,
        onItemSelected: (index) {
          _updateStatusBarStyle(index);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateStatusBarStyle(index);
          });
          setState(() {});
        },
        navBarStyle: NavBarStyle.style12,
        itemAnimationProperties: const ItemAnimationProperties(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: const ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
      ),
    );
  }
}
