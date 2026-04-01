import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/extensions/num_extensions.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/features/setting/presentation/widgets/profile_header.dart';
import 'package:account_ledger/features/setting/presentation/widgets/setting_tile.dart';
import 'package:flutter/material.dart';
// Import your widgets here

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              40.0.height,
              const ProfileHeader(),
              const SizedBox(height: 30),
              // The white settings container
              Container(
                padding: 16.allPadding,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
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
                    const SizedBox(height: 20),

                    SettingsTile(
                      icon: Icons.dark_mode,
                      iconBgColor: AppColors.darkIconBg,
                      title: 'Dark Mode',
                      trailing: Transform.scale(
                        scale: 0.8,
                        child: Switch(value: false, onChanged: (v) {}),
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.notifications,
                      iconBgColor: AppColors.notificationIconBg,
                      title: 'Notifications',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'On',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textHint,
                          ),
                        ],
                      ),
                    ),
                    const SettingsTile(
                      icon: Icons.lock,
                      iconBgColor: AppColors.privacyIconBg,
                      title: 'Privacy',
                    ),
                    const SettingsTile(
                      icon: Icons.security,
                      iconBgColor: AppColors.securityIconBg,
                      title: 'Security',
                    ),
                    const SizedBox(height: 10),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
