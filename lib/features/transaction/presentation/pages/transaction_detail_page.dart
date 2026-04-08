import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_detail_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// List responses include [TransactionEntity.direction]; the detail endpoint often does not.
/// Match server list logic: debit when the signed-in user's account is [fromParty].
bool _transactionIsDebitForViewer(TransactionEntity t, String myAccountId) {
  final explicit = t.direction?.toUpperCase();
  if (explicit == 'DEBIT') return true;
  if (explicit == 'CREDIT') return false;
  if (myAccountId.isEmpty) return false;
  final fromId = t.fromParty?.id ?? '';
  final toId = t.toParty?.id ?? '';
  if (fromId == myAccountId) return true;
  if (toId == myAccountId) return false;
  return false;
}

class TransactionDetailPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailPage({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransactionDetailBloc>()
            ..add(TransactionDetailLoadRequested(transactionId)),
      child: _TransactionDetailView(transactionId: transactionId),
    );
  }
}

class _TransactionDetailView extends StatelessWidget {
  final String transactionId;

  const _TransactionDetailView({required this.transactionId});

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(d.toLocal());
  }

  String _formatDateShort(DateTime? d) {
    if (d == null) return '—';
    return DateFormat('dd MMM yyyy').format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 14.w,
            color: AppColors.primaryTextColor(brightness),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Transaction', style: context.appFonts.boldBlack16),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionDetailBloc, TransactionDetailState>(
        builder: (context, state) {
          return switch (state) {
            TransactionDetailInitial() || TransactionDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            TransactionDetailFailure(:final message) => _FailureView(
              message: message,
              onRetry: () => context.read<TransactionDetailBloc>().add(
                TransactionDetailLoadRequested(transactionId),
              ),
              brightness: brightness,
            ),
            TransactionDetailLoaded(:final transaction) => _TransactionBody(
              transaction: transaction,
              brightness: brightness,
              isDark: isDark,
              formatDate: _formatDate,
              formatDateShort: _formatDateShort,
            ),
          };
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Main Body
// ─────────────────────────────────────────
class _TransactionBody extends StatelessWidget {
  final TransactionEntity transaction;
  final Brightness brightness;
  final bool isDark;
  final String Function(DateTime?) formatDate;
  final String Function(DateTime?) formatDateShort;

  const _TransactionBody({
    required this.transaction,
    required this.brightness,
    required this.isDark,
    required this.formatDate,
    required this.formatDateShort,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final accountState = context.watch<AccountBloc>().state;
    final myAccountId = switch (accountState) {
      AccountLoaded(:final account) when account != null => account.id,
      _ => '',
    };
    final isDebit = _transactionIsDebitForViewer(t, myAccountId);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero amount card ─────────────────────────
          _AmountHeroCard(
            transaction: t,
            isDebit: isDebit,
            brightness: brightness,
            isDark: isDark,
            formatDateShort: formatDateShort,
          ),

          24.0.height,

          // ── Transfer route ───────────────────────────
          _TransferRouteCard(transaction: t, brightness: brightness),

          24.0.height,

          // ── Transaction details ──────────────────────
          _DetailsCard(
            transaction: t,
            brightness: brightness,
            formatDate: formatDate,
          ),

          24.0.height,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Amount Hero Card
// ─────────────────────────────────────────
class _AmountHeroCard extends StatelessWidget {
  final TransactionEntity transaction;
  final bool isDebit;
  final Brightness brightness;
  final bool isDark;
  final String Function(DateTime?) formatDateShort;

  const _AmountHeroCard({
    required this.transaction,
    required this.isDebit,
    required this.brightness,
    required this.isDark,
    required this.formatDateShort,
  });

  Color get _amountColor =>
      isDebit ? const Color(0xFFFF3B30) : const Color(0xFF34C759);

  Color get _cardGradientStart => isDebit
      ? (isDark ? const Color(0xFF2A1215) : const Color(0xFFFFF1F0))
      : (isDark ? const Color(0xFF0D2318) : const Color(0xFFF0FFF4));

  Color get _cardGradientEnd => isDebit
      ? (isDark ? const Color(0xFF1C0A0A) : const Color(0xFFFFF8F7))
      : (isDark ? const Color(0xFF081A10) : const Color(0xFFF7FFFA));

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_cardGradientStart, _cardGradientEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _amountColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(22.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Direction badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DirectionBadge(isDebit: isDebit, color: _amountColor),
              ],
            ),

            22.0.height,

            // Amount
            Text(
              '${isDebit ? '-' : '+'}PKR ${_formatAmount(t.amount)}',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.w800,
                color: _amountColor,
                letterSpacing: -0.5,
              ),
            ),

            8.0.height,

            // Date
            Text(formatDateShort(t.createdAt), style: context.appFonts.grey14),

            if (t.description != null && t.description!.trim().isNotEmpty) ...[
              14.0.height,
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: _amountColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t.description!.trim(),
                  style: context.appFonts.grey14.copyWith(
                    color: _amountColor.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }
}

// ─────────────────────────────────────────
// Transfer Route Card
// ─────────────────────────────────────────
class _TransferRouteCard extends StatelessWidget {
  final TransactionEntity transaction;
  final Brightness brightness;

  const _TransferRouteCard({
    required this.transaction,
    required this.brightness,
  });

  String _partyName(TransactionPartyEntity? p) {
    if (p == null) return '—';
    final name = p.userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return p.accountTitle.isNotEmpty ? p.accountTitle : '—';
  }

  String _partyNumber(TransactionPartyEntity? p) {
    if (p == null) return '—';
    return p.accountNumber.isNotEmpty ? p.accountNumber : '—';
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.cardColor(brightness);
    final border = AppColors.borderColor(brightness);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transfer Route', style: context.appFonts.boldBlack14),

            16.0.height,

            // From party
            _PartyRow(
              label: 'From',
              name: _partyName(transaction.fromParty),
              accountNumber: _partyNumber(transaction.fromParty),
              brightness: brightness,
              avatarColor: const Color(0xFF4F8EF7),
            ),

            // Arrow connector
            Padding(
              padding: EdgeInsets.only(left: 19.w, top: 2.h, bottom: 2.h),
              child: Column(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Container(
                      width: 1.5,
                      height: 4.h,
                      color: AppColors.borderColor(brightness),
                    ),
                  ),
                ),
              ),
            ),

            // To party
            _PartyRow(
              label: 'To',
              name: _partyName(transaction.toParty),
              accountNumber: _partyNumber(transaction.toParty),
              brightness: brightness,
              avatarColor: const Color(0xFF34C759),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  final String label;
  final String name;
  final String accountNumber;
  final Brightness brightness;
  final Color avatarColor;

  const _PartyRow({
    required this.label,
    required this.name,
    required this.accountNumber,
    required this.brightness,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar circle
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: avatarColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: avatarColor,
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),

        14.0.width,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.borderColor(brightness),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryTextColor(brightness),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              4.0.height,
              Text(
                name,
                style: context.appFonts.boldBlack14,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              2.0.height,
              Text(accountNumber, style: context.appFonts.grey12),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Details Card
// ─────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final TransactionEntity transaction;
  final Brightness brightness;
  final String Function(DateTime?) formatDate;

  const _DetailsCard({
    required this.transaction,
    required this.brightness,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final cardBg = AppColors.cardColor(brightness);
    final border = AppColors.borderColor(brightness);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 12.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Details', style: context.appFonts.boldBlack14),
            ),
          ),
          Divider(height: 1, color: border),
          _DetailRow(
            label: 'Account No.',
            value: t.toParty?.accountNumber ?? "No Number",
            brightness: brightness,
            copyable: true,
          ),
          Divider(height: 1, color: border, indent: 18.w),
          _DetailRow(
            label: 'Date & Time',
            value: formatDate(t.createdAt),
            brightness: brightness,
          ),
          Divider(height: 1, color: border, indent: 18.w),
          _DetailRow(
            label: 'Status',
            value: t.status.toUpperCase(),
            brightness: brightness,
            isStatus: true,
            status: t.status,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Brightness brightness;
  final bool copyable;
  final bool isStatus;
  final String? status;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.brightness,
    this.copyable = false,
    this.isStatus = false,
    this.status,
  });

  Color _statusColor() {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return const Color(0xFF34C759);
      case 'PENDING':
        return const Color(0xFFFF9F0A);
      case 'FAILED':
        return const Color(0xFFFF3B30);
      case 'REVERSED':
        return const Color(0xFF007AFF);
      default:
        return const Color(0xFF8E8E93);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 13.h),
      child: Row(
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: context.appFonts.grey12),
          ),
          Expanded(
            child: isStatus
                ? Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor(),
                        ),
                      ),
                      6.0.width,
                      Text(
                        value,
                        style: context.appFonts.boldBlack12.copyWith(
                          color: _statusColor(),
                        ),
                      ),
                    ],
                  )
                : Text(
                    value.isEmpty ? '—' : value,
                    style: context.appFonts.black14,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: value));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied to clipboard'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.copy_rounded,
                  size: 15.w,
                  color: AppColors.secondaryTextColor(brightness),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Direction Badge
// ─────────────────────────────────────────
class _DirectionBadge extends StatelessWidget {
  final bool isDebit;
  final Color color;

  const _DirectionBadge({required this.isDebit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDebit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12.w,
            color: color,
          ),
          5.0.width,
          Text(
            isDebit ? 'Sent' : 'Received',
            style: TextStyle(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Failure View
// ─────────────────────────────────────────
class _FailureView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Brightness brightness;

  const _FailureView({
    required this.message,
    required this.onRetry,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.w,
              color: AppColors.disableColor,
            ),
            16.0.height,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.appFonts.grey14,
            ),
            20.0.height,
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
