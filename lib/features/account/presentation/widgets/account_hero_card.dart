import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountHeroCard extends StatelessWidget {
  final AccountEntity account;
  final String Function(DateTime?) formatDate;
  final String status;

  const AccountHeroCard({
    super.key,
    required this.account,
    required this.formatDate,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'ACTIVE':
        return AppColors.success;
      case 'FROZEN':
        return AppColors.warning;
      case 'CLOSED':
        return AppColors.disableColor;
      default:
        return AppColors.primary;
    }
  }

  /// Formats account number with spaces every 4 chars for readability.
  String get _formattedNumber {
    final raw = account.accountNumber.replaceAll(RegExp(r'\s'), '');
    if (raw.length <= 4) return raw;
    final buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('  ');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: brightness == Brightness.dark
              ? [const Color(0xFF1A2744), const Color(0xFF0F1B36)]
              : [const Color(0xFF0F2057), const Color(0xFF1A3A8F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2057).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: 40,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          // Card content
          Padding(
            padding: EdgeInsets.all(22.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: Title + Status ────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.accountTitle,
                            style: context.appFonts.boldBlack20.copyWith(
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.0.height,
                          Text(
                            'Personal Wallet',
                            style: context.appFonts.grey12.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(status: status, color: _statusColor),
                  ],
                ),

                26.0.height,

                // ── Account number label ─────────────
                Text(
                  'ACCOUNT NUMBER',
                  style: context.appFonts.grey12.copyWith(
                    color: Colors.white38,
                    letterSpacing: 1.5,
                    fontSize: 10.sp,
                  ),
                ),
                8.0.height,

                // ── Account number + copy ────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _formattedNumber,
                        style: context.appFonts.boldBlack20.copyWith(
                          color: Colors.white,
                          letterSpacing: 2.0,
                          fontSize: 17.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.0.width,
                    _CopyButton(accountNumber: account.accountNumber),
                  ],
                ),

                24.0.height,

                // ── Divider ──────────────────────────
                Divider(
                  color: Colors.white.withValues(alpha: 0.1),
                  thickness: 1,
                  height: 1,
                ),

                20.0.height,

                // ── Row 3: Meta info ─────────────────
                Row(
                  children: [
                    _MetaItem(label: 'CURRENCY', value: account.currency),
                    _VerticalDivider(),
                    _MetaItem(
                      label: 'MEMBER SINCE',
                      value: formatDate(account.createdAt).split(',').first,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Status Badge
// ─────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          6.0.width,
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Copy Button
// ─────────────────────────────────────────
class _CopyButton extends StatelessWidget {
  final String accountNumber;

  const _CopyButton({required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: accountNumber));
        if (!context.mounted) return;
        CustomSnackBar.show(
          context,
          message: 'Account number copied',
          type: SnackBarType.success,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.copy_rounded, size: 13.w, color: Colors.white70),
            5.0.width,
            Text(
              'Copy',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Meta Item
// ─────────────────────────────────────────
class _MetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9.sp,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          5.0.height,
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Vertical Divider
// ─────────────────────────────────────────
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: Colors.white.withValues(alpha: 0.12),
    );
  }
}
