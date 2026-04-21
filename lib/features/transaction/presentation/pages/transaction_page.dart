import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:account_ledger/features/beneficiary/presentation/widgets/beneficiary_picker_sheet.dart';
import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_entity.dart';
import 'package:account_ledger/features/transaction/domain/entities/transaction_party_entity.dart';
import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TransactionView();
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
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
      TransactionLoadRequested(page: 1, limit: 3),
    );
  }

  @override
  void dispose() {
    _toAccountController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _promptPinAndSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final pin = await _showPinDialog(context);
    if (!mounted || pin == null) return;
    context.read<TransactionBloc>().add(
      TransferWithPinSubmitted(
        pin: pin,
        toAccount: _toAccountController.text,
        amount: _amountController.text,
        description: _descriptionController.text,
      ),
    );
  }

  Future<void> _pickBeneficiary() async {
    // Ensure list is loaded at least once.
    final bloc = context.read<BeneficiaryBloc>();
    if (bloc.state.items.isEmpty && !bloc.state.loading) {
      bloc.add(const BeneficiariesRefreshRequested());
    }
    final selected = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return BlocBuilder<BeneficiaryBloc, BeneficiaryState>(
          builder: (context, state) {
            return BeneficiaryPickerSheet(items: state.items);
          },
        );
      },
    );
    if (!mounted || selected == null) return;
    // Fill recipient account field
    final b = selected as BeneficiaryEntity;
    final accountNumber = b.accountNumber;
    if (accountNumber.isEmpty) return;
    setState(() => _toAccountController.text = accountNumber);
  }

  Future<String?> _showPinDialog(BuildContext context) async {
    final controller = PinInputController();
    var enabled = false;

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Enter PIN'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your 4-digit PIN to confirm this transfer.',
                    style: ctx.appFonts.grey14,
                  ),
                  SizedBox(height: 16.h),
                  MaterialPinField(
                    length: 4,
                    pinController: controller,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() => enabled = v.length == 4),
                    onCompleted: (_) {
                      if (enabled) Navigator.of(ctx).pop(controller.text);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: enabled
                      ? () => Navigator.of(ctx).pop(controller.text)
                      : null,
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
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
          final code = state.errorCode ?? '';
          final msg = state.errorMessage!.toLowerCase();
          final looksLikePinFreeze =
              code.contains('403') ||
              (msg.contains('frozen') && msg.contains('attempt'));
          if (looksLikePinFreeze) {
            // Server may have set account to FROZEN — refresh wallet status for Account tab.
            context.read<AccountBloc>().add(const AccountLoadRequested());
          }
          context.read<TransactionBloc>().add(
            const TransactionMessageConsumed(),
          );
        } else if (state.successMessage != null) {
          CustomSnackBar.show(
            context,
            message: state.successMessage!,
            type: SnackBarType.success,
          );
          if (state.successMessage == 'Transfer completed successfully.') {
            _toAccountController.clear();
            _amountController.clear();
            _descriptionController.clear();
          }
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
                          TransactionLoadRequested(page: 1, limit: 3),
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
                    TransactionLoadRequested(page: 1, limit: 3),
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
                              SizedBox(height: 10.h),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton.icon(
                                      onPressed: _pickBeneficiary,
                                      icon: const Icon(
                                        Icons.people_alt_rounded,
                                      ),
                                      label: const Text('Choose beneficiary'),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),

                              CustomTextField(
                                controller: _toAccountController,
                                label: 'Recipient account number',
                                keyboardType: TextInputType.number,
                                hint: 'Enter recipient account number',
                                validator: (v) => Validators.required(
                                  v,
                                  'Recipient account number',
                                ),
                              ),
                              SizedBox(height: 10.h),

                              SizedBox(height: 12.h),

                              CustomTextField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
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
                                onPressed: state.isSending
                                    ? () {}
                                    : _promptPinAndSubmit,
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
                                  TextButton(
                                    onPressed: () => context.push(
                                      RouteEndpoints.transactionHistory,
                                    ),
                                    child: Text(
                                      'View All',
                                      style: context.appFonts.boldBlack14
                                          .copyWith(color: scheme.primary),
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
                                              _counterpartyLabel(t),
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
                                        _formatWhen(t.createdAt),
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
                    // if (state.pagination.hasNextPage)
                    //   SliverToBoxAdapter(
                    //     child: Padding(
                    //       padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                    //       child: OutlinedButton(
                    //         onPressed: state.isLoadingMore
                    //             ? null
                    //             : () => context.read<TransactionBloc>().add(
                    //                 const TransactionLoadMoreRequested(),
                    //               ),
                    //         child: state.isLoadingMore
                    //             ? const SizedBox(
                    //                 width: 22,
                    //                 height: 22,
                    //                 child: CircularProgressIndicator(
                    //                   strokeWidth: 2,
                    //                 ),
                    //               )
                    //             : const Text('See More'),
                    //       ),
                    //     ),
                    //   )
                    // else
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
