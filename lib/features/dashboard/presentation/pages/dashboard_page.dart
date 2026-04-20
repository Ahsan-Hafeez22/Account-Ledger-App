import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/widgets/add_beneficiary_sheet.dart';
import 'package:account_ledger/features/beneficiary/presentation/widgets/beneficiary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final secondary =
        AppColors.secondaryTextColor(Theme.of(context).brightness);
    final user =
        context.select<AuthBloc, AuthAuthenticated?>(
          (b) => b.state is AuthAuthenticated ? b.state as AuthAuthenticated : null,
        )?.user;

    return BlocConsumer<BeneficiaryBloc, BeneficiaryState>(
      listenWhen: (p, c) => p.message != c.message || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          CustomSnackBar.show(
            context,
            message: state.errorMessage!,
            type: SnackBarType.error,
          );
          context.read<BeneficiaryBloc>().add(const BeneficiaryMessageConsumed());
        } else if (state.message != null) {
          CustomSnackBar.show(
            context,
            message: state.message!,
            type: SnackBarType.success,
          );
          context.read<BeneficiaryBloc>().add(const BeneficiaryMessageConsumed());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<BeneficiaryBloc>().add(const BeneficiariesRefreshRequested());
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
                      child: _DashboardHeader(
                        userName: user?.name ?? 'Account Ledger',
                        subtitle: 'Quick access to your saved beneficiaries.',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _QuickActionsRow(
                        onAdd: () async {
                          final result = await showModalBottomSheet<Map<String, String>>(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: true,
                            builder: (_) => const AddBeneficiarySheet(),
                          );
                          if (!context.mounted || result == null) return;
                          final account = result['accountNumber'] ?? '';
                          final nickname = result['nickname'] ?? '';
                          if (account.isEmpty || nickname.isEmpty) return;
                          context.read<BeneficiaryBloc>().add(
                                BeneficiaryAddRequested(
                                  accountNumber: account,
                                  nickname: nickname,
                                ),
                              );
                        },
                        onRefresh: () => context
                            .read<BeneficiaryBloc>()
                            .add(const BeneficiariesRefreshRequested()),
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
                        child: _EmptyBeneficiariesCard(
                          onAdd: () async {
                            final result = await showModalBottomSheet<Map<String, String>>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              builder: (_) => const AddBeneficiarySheet(),
                            );
                            if (!context.mounted || result == null) return;
                            context.read<BeneficiaryBloc>().add(
                                  BeneficiaryAddRequested(
                                    accountNumber: result['accountNumber'] ?? '',
                                    nickname: result['nickname'] ?? '',
                                  ),
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
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String userName;
  final String subtitle;

  const _DashboardHeader({
    required this.userName,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.65),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, ${userName.split(' ').first}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.people_alt_rounded, color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  const _QuickActionsRow({
    required this.onAdd,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add beneficiary'),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
        ),
      ],
    );
  }
}

class _EmptyBeneficiariesCard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBeneficiariesCard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_search_rounded, color: scheme.onSecondaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No beneficiaries yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Save frequently used recipients here for faster transfers.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add your first beneficiary'),
          ),
        ],
      ),
    );
  }
}
