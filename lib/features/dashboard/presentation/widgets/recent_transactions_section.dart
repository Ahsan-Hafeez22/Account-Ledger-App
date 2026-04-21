import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({super.key});

  String _counterpartyLabel(TransactionEntity t) {
    final dir = t.direction?.toUpperCase();
    TransactionPartyEntity? other;
    if (dir == 'DEBIT') {
      other = t.toParty;
    } else if (dir == 'CREDIT') {
      other = t.fromParty;
    } else {
      other = t.toParty ?? t.fromParty;
    }
    if (other == null) return '—';
    final name = other.userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return other.accountTitle.isNotEmpty ? other.accountTitle : other.accountNumber;
  }

  String _formatWhen(DateTime? d) {
    if (d == null) return '—';
    return DateFormat.yMMMd().add_jm().format(d.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = AppColors.secondaryTextColor(Theme.of(context).brightness);

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final loaded = state is TransactionLoaded ? state : null;
        final items = loaded?.transactions ?? const <TransactionEntity>[];
        final top = items.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Recent activity',
                  style: context.appFonts.boldBlack18.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(RouteEndpoints.transactionHistory),
                  child: Text(
                    'View All',
                    style: context.appFonts.boldBlack14.copyWith(color: scheme.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (top.isEmpty)
              Text(
                'No transactions yet.',
                style: context.appFonts.grey14.copyWith(color: secondary),
              )
            else
              ...top.map((t) {
                final isDebit = t.direction?.toUpperCase() == 'DEBIT';
                final chipColor = isDebit ? scheme.errorContainer : scheme.primaryContainer;
                final chipFg = isDebit ? scheme.onErrorContainer : scheme.onPrimaryContainer;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Material(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(
                        RouteEndpoints.transactionDetailPath(t.id),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: chipColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isDebit ? 'Sent' : 'Received',
                                    style: context.appFonts.mediumBlack12.copyWith(color: chipFg),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${isDebit ? '-' : '+'}${t.amount.toStringAsFixed(2)}',
                                  style: context.appFonts.boldBlack16.copyWith(
                                    color: isDebit ? scheme.error : scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _counterpartyLabel(t),
                              style: context.appFonts.boldBlack14.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatWhen(t.createdAt),
                              style: context.appFonts.grey12.copyWith(color: secondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

