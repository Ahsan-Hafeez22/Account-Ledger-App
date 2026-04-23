import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/widgets/beneficiary_card.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/dashboard_header_widget.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/empty_benificiary_card_widget.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/quick_action_row_widget.dart';
import 'package:account_ledger/features/dashboard/presentation/bloc/balance_bloc.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/profile_summary_card.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/account_info_card.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/features/account/presentation/widgets/change_pin_sheet.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/widgets/add_beneficiary_flow_sheet.dart';
import 'package:account_ledger/features/dashboard/presentation/widgets/notification_bell_button.dart';
import 'package:account_ledger/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:account_ledger/core/routes/route_names.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  PersistentBottomSheetController? _pinSheet;
  String _lastBalanceAccountNumber = '';

  @override
  void initState() {
    super.initState();
    // Make sure we have latest account + small transactions list.
    context.read<AccountBloc>().add(const AccountLoadRequested());
    context.read<BeneficiaryBloc>().add(const BeneficiariesRefreshRequested());
    context.read<TransactionBloc>().add(
      const TransactionLoadRequested(page: 1, limit: 3),
    );
    context.read<NotificationBloc>().add(NotificationsLoadRequested());
  }

  @override
  void dispose() {
    _pinSheet?.close();
    super.dispose();
  }

  void _openChangePinSheet() {
    final brightness = Theme.of(context).brightness;
    _pinSheet?.close();
    _pinSheet = Scaffold.of(context).showBottomSheet(
      (ctx) => ChangePinSheet(
        brightness: brightness,
        onDismiss: () {
          _pinSheet?.close();
          _pinSheet = null;
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary = AppColors.secondaryTextColor(
      Theme.of(context).brightness,
    );
    final user = context
        .select<AuthBloc, AuthAuthenticated?>(
          (b) => b.state is AuthAuthenticated
              ? b.state as AuthAuthenticated
              : null,
        )
        ?.user;

    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (p, c) {
        if (c is! TransactionLoaded) return false;
        if (c.successMessage == null || c.successMessage!.isEmpty) return false;
        final prev = p is TransactionLoaded ? p.successMessage : null;
        return prev != c.successMessage;
      },
      listener: (context, txState) {
        if (txState is! TransactionLoaded) return;
        if (txState.successMessage != 'Transfer completed successfully.')
          return;

        // Always re-fetch balance after a successful transfer.
        final accountState = context.read<AccountBloc>().state;
        final account = accountState is AccountLoaded
            ? accountState.account
            : null;
        final acctNo = account?.accountNumber ?? _lastBalanceAccountNumber;
        if (acctNo.isNotEmpty) {
          context.read<BalanceBloc>().add(
            BalanceRefreshRequested(accountNumber: acctNo),
          );
        }

        // Also refresh account (status/title, etc.) if needed.
        context.read<AccountBloc>().add(const AccountLoadRequested());

        // Prevent repeated triggers on rebuilds.
        context.read<TransactionBloc>().add(const TransactionMessageConsumed());
      },
      child: BlocConsumer<BeneficiaryBloc, BeneficiaryState>(
        listenWhen: (p, c) =>
            p.message != c.message || p.errorMessage != c.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            CustomSnackBar.show(
              context,
              message: state.errorMessage!,
              type: SnackBarType.error,
            );
            context.read<BeneficiaryBloc>().add(
              const BeneficiaryMessageConsumed(),
            );
          } else if (state.message != null) {
            CustomSnackBar.show(
              context,
              message: state.message!,
              type: SnackBarType.success,
            );
            context.read<BeneficiaryBloc>().add(
              const BeneficiaryMessageConsumed(),
            );
          }
        },
        builder: (context, state) {
          final accountState = context.watch<AccountBloc>().state;
          final account = accountState is AccountLoaded
              ? accountState.account
              : null;
          if (account != null) {
            // Ensure balance is loaded for current account.
            if (_lastBalanceAccountNumber != account.accountNumber) {
              _lastBalanceAccountNumber = account.accountNumber;
              context.read<BalanceBloc>().add(
                BalanceLoadRequested(accountNumber: account.accountNumber),
              );
            }
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<BeneficiaryBloc>().add(
                    const BeneficiariesRefreshRequested(),
                  );
                  context.read<AccountBloc>().add(const AccountLoadRequested());
                  if (account != null) {
                    context.read<BalanceBloc>().add(
                      BalanceRefreshRequested(
                        accountNumber: account.accountNumber,
                      ),
                    );
                  }
                  context.read<TransactionBloc>().add(
                    const TransactionLoadRequested(page: 1, limit: 3),
                  );
                  context.read<NotificationBloc>().add(
                    const NotificationsRefreshRequested(),
                  );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 4.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dashboard',
                                style: context.appFonts.boldBlack18.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Chat',
                              onPressed: () {
                                context.push(RouteEndpoints.chats);
                              },
                              icon: Icon(
                                Icons.chat_bubble_outline,
                                color: scheme.onSurface,
                              ),
                            ),
                            const NotificationBellButton(),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: BalanceCard(
                          currency:
                              account?.currency ??
                              (user?.defaultCurrency ?? 'PKR'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
                        child: user == null
                            ? const SizedBox.shrink()
                            : ProfileSummaryCard(user: user),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 0.h)),
                    if (account != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: AccountInfoCard(
                            account: account,
                            onChangePin: _openChangePinSheet,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(child: SizedBox(height: 18.h)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const RecentTransactionsSection(),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 18.h)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
                        child: DashboardHeader(
                          userName: user?.name ?? 'Account Ledger',
                          subtitle: 'Manage your saved beneficiaries',
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: QuickActionsRow(
                          onAdd: () async {
                            await showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              builder: (_) => const AddBeneficiaryFlowSheet(),
                            );
                          },
                          onRefresh: () => context.read<BeneficiaryBloc>().add(
                            const BeneficiariesRefreshRequested(),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 16.h)),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Text(
                              'Beneficiaries',
                              style: context.appFonts.boldBlack18.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${state.items.length}',
                              style: context.appFonts.mediumBlack12.copyWith(
                                color: secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                    if (state.loading)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 28),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    else if (state.items.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 60.h),
                          child: EmptyBeneficiariesCard(
                            onAdd: () async {
                              await showModalBottomSheet<bool>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (_) => const AddBeneficiaryFlowSheet(),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final b = state.items[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: BeneficiaryCard(
                              beneficiary: b,
                              deleting: state.busyIds.contains(b.id),
                              onDelete: () => context
                                  .read<BeneficiaryBloc>()
                                  .add(BeneficiaryDeleteRequested(b.id)),
                            ),
                          );
                        },
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
