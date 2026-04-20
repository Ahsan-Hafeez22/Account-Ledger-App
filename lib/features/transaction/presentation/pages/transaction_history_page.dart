import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:account_ledger/features/transaction/presentation/widgets/helper_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final int _selectedLimit = 10;
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
      TransactionLoadRequested(page: 1, limit: _selectedLimit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = AppColors.secondaryTextColor(
      Theme.of(context).brightness,
    );

    return BlocConsumer<TransactionBloc, TransactionState>(
      listenWhen: (prev, next) {
        if (next is TransactionLoaded) {
          return next.errorMessage != null || next.successMessage != null;
        }
        return false;
      },
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.scaffoldBg,
          body: SafeArea(
            child: switch (state) {
              TransactionInitial() || TransactionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              TransactionFailure(:final message) => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: context.appFonts.grey14.copyWith(
                          color: secondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FilledButton(
                        onPressed: () => context.read<TransactionBloc>().add(
                          TransactionLoadRequested(
                            page: 1,
                            limit: _selectedLimit,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              TransactionLoaded() => RefreshIndicator(
                onRefresh: () async {
                  context.read<TransactionBloc>().add(
                    TransactionLoadRequested(page: 1, limit: _selectedLimit),
                  );
                  await context.read<TransactionBloc>().stream.firstWhere(
                    (s) => s is TransactionLoaded || s is TransactionFailure,
                  );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: GoRouter.of(context).pop,
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary),
                                ),
                                child: Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Transaction History',
                              style: context.appFonts.boldBlack24.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Here you can see the transaction history of your account.',
                              style: context.appFonts.grey14.copyWith(
                                color: secondary,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            Row(
                              children: [
                                Text(
                                  'Recent activity',
                                  style: context.appFonts.boldBlack18.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ),
                    if (state.transactions.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Text(
                            'No transactions yet.',
                            style: context.appFonts.grey14.copyWith(
                              color: secondary,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount: state.transactions.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final t = state.transactions[index];
                          final isDebit = t.direction?.toUpperCase() == 'DEBIT';
                          final chipColor = isDebit
                              ? scheme.errorContainer
                              : scheme.primaryContainer;
                          final chipFg = isDebit
                              ? scheme.onErrorContainer
                              : scheme.onPrimaryContainer;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Material(
                              color: scheme.surfaceContainerHighest.withValues(
                                alpha: 0.35,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => context.push(
                                  RouteEndpoints.transactionDetailPath(t.id),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isDebit ? 'Sent' : 'Received',
                                              style: context
                                                  .appFonts
                                                  .mediumBlack12
                                                  .copyWith(color: chipFg),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${isDebit ? '-' : '+'}${t.amount.toStringAsFixed(2)}',
                                            style: context.appFonts.boldBlack16
                                                .copyWith(
                                                  color: isDebit
                                                      ? scheme.error
                                                      : scheme.primary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              counterpartyLabel(t),
                                              style: context
                                                  .appFonts
                                                  .boldBlack14
                                                  .copyWith(
                                                    color: scheme.onSurface,
                                                  ),
                                            ),
                                          ),
                                          Spacer(),
                                          Expanded(
                                            child: Text(
                                              t.fromParty?.accountNumber ?? '',
                                              style: context.appFonts.black14
                                                  .copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: scheme.onSurface,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        t.fromParty?.userEmail ?? '',
                                        style: context.appFonts.grey12.copyWith(
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      // SizedBox(height: 4.h),
                                      Text(
                                        formatWhen(t.createdAt),
                                        style: context.appFonts.grey12.copyWith(
                                          color: secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    if (state.pagination.hasNextPage)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                          child: OutlinedButton(
                            onPressed: state.isLoadingMore
                                ? null
                                : () => context.read<TransactionBloc>().add(
                                    const TransactionLoadMoreRequested(),
                                  ),
                            child: state.isLoadingMore
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('See More'),
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  ],
                ),
              ),
            },
          ),
        );
      },
    );
  }
}
