import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/num_extensions.dart';
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: 8.allPadding,
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title, style: AppFonts.mediumBlack16),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textHint,
          ),
    );
  }
}
