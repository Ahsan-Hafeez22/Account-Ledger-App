import 'dart:developer';

import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/core/theme/theme_cubit.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/setting/presentation/widgets/profile_header.dart';
import 'package:account_ledger/features/setting/presentation/widgets/setting_tile.dart';
import 'package:account_ledger/shared/components/alert_box_widget.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static const Color _deleteIconBg = Color(0xFFE53935);

  /// True only while the full-screen loading dialog from delete / logout is shown.
  /// Prevents [Navigator.pop] from popping a pushed route (e.g. change-password) when
  /// another feature emits [AuthLoading] → [AuthFailure] on the same [AuthBloc].
  bool _rootLoadingDialogOpen = false;

  Future<void> _confirmDelete(BuildContext context) async {
    bool go = await AppAlertDialog.show(
      context: context,
      type: DialogType.warning,
      customIcon: Icons.delete,
      iconColor: Colors.red,
      cancelText: 'cancel',
      showCancelButton: true,
      title: "Alert",

      messageStyle: context.appFonts.black12,
      message:
          "Do you really want to delete? Your account will be permenantly deleted and you will lose all the access.",
      confirmButtonColor: Colors.red,
      onConfirm: () =>
          context.read<AuthBloc>().add(const AuthDeleteAccountRequested()),
    );
    if (go != true || !context.mounted) return;
    setState(() => _rootLoadingDialogOpen = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _confirmLogout(BuildContext context) async {
    bool go = await AppAlertDialog.show(
      context: context,
      type: DialogType.info,
      customIcon: Icons.logout,
      iconColor: Colors.red,
      cancelText: 'cancel',
      showCancelButton: true,
      title: "Logout",
      messageStyle: context.appFonts.black14,
      message: "Do you really want to Logout? You can login again later.",
      confirmButtonColor: Colors.red,
      onConfirm: () =>
          context.read<AuthBloc>().add(const AuthLogoutRequested()),
    );
    if (go != true || !context.mounted) return;
    setState(() => _rootLoadingDialogOpen = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (current is AuthFailure || current is AuthUnauthenticated) &&
          previous is AuthLoading,
      listener: (context, state) {
        if (!_rootLoadingDialogOpen) return;
        final nav = Navigator.of(context, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
        setState(() => _rootLoadingDialogOpen = false);
        if (state is AuthFailure) {
          CustomSnackBar.show(
            context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                40.0.height,
                const ProfileHeader(),
                const SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 40.h,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      20.0.height,
                      SettingsTile(
                        icon: Icons.dark_mode,
                        iconBgColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceHighlight
                            : AppColors.blackColor,
                        title: 'Dark Mode',
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: BlocBuilder<ThemeCubit, ThemeMode>(
                            buildWhen: (p, c) => p != c,
                            builder: (context, _) {
                              final cubit = context.read<ThemeCubit>();
                              return Switch(
                                value: cubit.isDarkActiveFor(context),
                                onChanged: (enabled) =>
                                    cubit.setDarkModeEnabled(enabled),
                              );
                            },
                          ),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.notifications,
                        iconBgColor: AppColors.notificationColor,
                        title: 'Notifications',
                        onTap: () => context.push(RouteEndpoints.notifications),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'On',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ],
                        ),
                      ),
                      const SettingsTile(
                        icon: Icons.lock,
                        iconBgColor: AppColors.privacyIconBg,
                        title: 'Privacy',
                      ),
                      SettingsTile(
                        icon: Icons.security,
                        iconBgColor: AppColors.securityIconBg,
                        title: 'Security',
                        onTap: () =>
                            context.push(RouteEndpoints.changePassword),
                      ),
                      const SettingsTile(
                        icon: Icons.person,
                        iconBgColor: AppColors.accountIconBg,
                        title: 'Account',
                      ),
                      const SettingsTile(
                        icon: Icons.help_outline,
                        iconBgColor: AppColors.helpIconBg,
                        title: 'Help',
                      ),
                      const SettingsTile(
                        icon: Icons.info_outline,
                        iconBgColor: AppColors.aboutIconBg,
                        title: 'About',
                      ),

                      SettingsTile(
                        icon: Icons.delete_outline,
                        iconBgColor: _deleteIconBg,
                        title: 'Delete account',
                        onTap: () => _confirmDelete(context),
                      ),

                      20.0.height,
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthUnauthenticated) {
                            CustomSnackBar.show(
                              context,
                              message: "Logout Success",
                              type: SnackBarType.success,
                            );
                            context.go(RouteEndpoints.login);
                          } else if (state is AuthFailure) {
                            log("Error: ${state.message}");
                            CustomSnackBar.show(
                              context,
                              message: state.message,
                              type: SnackBarType.error,
                            );
                          }
                        },
                        builder: (context, state) {
                          return CustomButton(
                            icon: Icon(Icons.logout_rounded),
                            backgroundColor: AppColors.error,
                            isLoading: state is AuthLoading,
                            text: 'Logout',

                            onPressed: () => _confirmLogout(context),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
