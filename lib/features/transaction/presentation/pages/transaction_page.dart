import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<TransactionBloc>()..add(const TransactionLoadRequested()),
      child: const _TransactionView(),
    );
  }
}

class _TransactionView extends StatefulWidget {
  const _TransactionView();

  @override
  State<_TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<_TransactionView> {
  final _formKey = GlobalKey<FormState>();
  final _toAccountController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _toAccountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<TransactionBloc>().add(
      TransferSubmitted(
        toAccount: _toAccountController.text,
        amount: _amountController.text,
        description: _descriptionController.text,
      ),
    );
  }

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
    return other.accountTitle.isNotEmpty
        ? other.accountTitle
        : other.accountNumber;
  }

  String _formatWhen(DateTime? d) {
    if (d == null) return '—';
    return DateFormat.yMMMd().add_jm().format(d.toLocal());
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
      listener: (context, state) {
        if (state is! TransactionLoaded) return;
        if (state.errorMessage != null) {
          CustomSnackBar.show(
            context,
            message: state.errorMessage!,
            type: SnackBarType.error,
          );
          context.read<TransactionBloc>().add(
            const TransactionMessageConsumed(),
          );
        } else if (state.successMessage != null) {
          CustomSnackBar.show(
            context,
            message: state.successMessage!,
            type: SnackBarType.success,
          );
          context.read<TransactionBloc>().add(
            const TransactionMessageConsumed(),
          );
        }
      },
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
                          const TransactionLoadRequested(),
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
                    const TransactionLoadRequested(),
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.h),
                              Text(
                                'Send money',
                                style: context.appFonts.boldBlack24.copyWith(
                                  color: scheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Transfers use an idempotency key so retries stay safe if the network drops.',
                                style: context.appFonts.grey14.copyWith(
                                  color: secondary,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              // TextFormField(

                              //   controller: _toAccountController,
                              //   decoration: const InputDecoration(
                              //     labelText: 'Recipient account number',
                              //     border: OutlineInputBorder(),
                              //   ),
                              //   textInputAction: TextInputAction.next,
                              //   validator: (v) {
                              //     if (v == null || v.trim().isEmpty) {
                              //       return 'Required';
                              //     }
                              //     return null;
                              //   },
                              // ),
                              CustomTextField(
                                controller: _toAccountController,
                                label: 'Recipient account number',
                                hint: 'Enter recipient account number',
                                validator: (v) => Validators.required(
                                  v,
                                  'Recipient account number',
                                ),
                              ),
                              SizedBox(height: 12.h),
                              // TextFormField(
                              //   controller: _amountController,
                              //   decoration: const InputDecoration(
                              //     labelText: 'Amount',
                              //     border: OutlineInputBorder(),
                              //   ),
                              //   keyboardType:
                              //       const TextInputType.numberWithOptions(
                              //         decimal: true,
                              //       ),
                              //   textInputAction: TextInputAction.next,
                              //   validator: (v) {
                              //     final n = double.tryParse(v?.trim() ?? '');
                              //     if (n == null || n <= 0) {
                              //       return 'Enter a valid amount';
                              //     }
                              //     return null;
                              //   },
                              // ),
                              CustomTextField(
                                controller: _amountController,
                                label: 'Amount',
                                hint: 'Enter ammount',
                                validator: (v) =>
                                    Validators.required(v, 'Amount Required'),
                              ),
                              SizedBox(height: 12.h),

                              CustomTextField(
                                controller: _descriptionController,
                                label: 'Description (optional)',
                                hint: 'Enter purpose of transfer',
                                validator: (v) => null,
                              ),

                              SizedBox(height: 20.h),
                              CustomButton(
                                text: 'Send transfer',

                                isLoading: state.isSending,
                                onPressed: state.isSending ? () {} : _submit,
                              ),
                              SizedBox(height: 28.h),
                              Row(
                                children: [
                                  Text(
                                    'Recent activity',
                                    style: context.appFonts.boldBlack18
                                        .copyWith(color: scheme.onSurface),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${state.pagination.total} total',
                                    style: context.appFonts.grey12.copyWith(
                                      color: secondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                            ],
                          ),
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
                              child: Padding(
                                padding: EdgeInsets.all(16.w),
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
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
                                    Text(
                                      _counterpartyLabel(t),
                                      style: context.appFonts.black14.copyWith(
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatWhen(t.createdAt),
                                      style: context.appFonts.grey12.copyWith(
                                        color: secondary,
                                      ),
                                    ),
                                  ],
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
                                : const Text('Load more'),
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
