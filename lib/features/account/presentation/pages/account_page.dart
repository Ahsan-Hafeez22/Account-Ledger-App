import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_colors.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/features/account/presentation/widgets/account_hero_card.dart';
import 'package:account_ledger/features/account/presentation/widgets/account_registration_form.dart';
import 'package:account_ledger/features/account/presentation/widgets/account_security_section.dart';
import 'package:account_ledger/features/account/presentation/widgets/account_status_section.dart';
import 'package:account_ledger/features/account/presentation/widgets/change_pin_sheet.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(const AccountLoadRequested()),
      child: const _AccountView(),
    );
  }
}

class _AccountView extends StatefulWidget {
  const _AccountView();

  @override
  State<_AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<_AccountView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pinController = TextEditingController();
  PersistentBottomSheetController? _bottomSheetController;

  @override
  void dispose() {
    _titleController.dispose();
    _pinController.dispose();
    _bottomSheetController?.close();
    super.dispose();
  }

  void _submitCreate() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AccountBloc>().add(
      AccountCreateRequested(
        accountTitle: _titleController.text,
        pin: _pinController.text,
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return DateFormat.yMMMd().add_jm().format(d.toLocal());
  }

  void _openChangePinSheet(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    _bottomSheetController?.close();
    _bottomSheetController = Scaffold.of(context).showBottomSheet(
      (ctx) => ChangePinSheet(
        brightness: brightness,
        onDismiss: () {
          _bottomSheetController?.close();
          _bottomSheetController = null;
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    _bottomSheetController?.closed.whenComplete(() {
      if (_bottomSheetController != null) _bottomSheetController = null;
    });
  }

  Future<void> _confirmStatusChange(BuildContext context, String next) async {
    final state = context.read<AccountBloc>().state;
    if (state is! AccountLoaded || state.account == null) return;
    final current = state.account!.status.toUpperCase();
    final nextUpper = next.toUpperCase();
    if (current == nextUpper) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Account Status'),
        content: Text(
          'Are you sure you want to change the status from $current to $nextUpper?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<AccountBloc>().add(ChangeAccountStatusRequested(status: next));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AccountBloc, AccountState>(
          listenWhen: (prev, curr) {
            if (curr is AccountLoaded &&
                curr.errorMessage != null &&
                curr.errorMessage!.isNotEmpty)
              return true;
            if (prev is AccountLoaded &&
                curr is AccountLoaded &&
                prev.account == null &&
                curr.account != null)
              return true;
            if (curr is AccountLoaded &&
                curr.successMessage != null &&
                curr.successMessage!.isNotEmpty)
              return true;
            return false;
          },
          listener: (context, state) {
            if (state is! AccountLoaded) return;
            if (state.errorMessage != null) {
              CustomSnackBar.show(
                context,
                message: state.errorMessage!,
                type: SnackBarType.error,
              );
              context.read<AccountBloc>().add(const AccountErrorConsumed());
              return;
            }
            if (state.successMessage != null) {
              CustomSnackBar.show(
                context,
                message: state.successMessage!,
                type: SnackBarType.success,
              );
              _bottomSheetController?.close();
              _bottomSheetController = null;
              context.read<AccountBloc>().add(const AccountErrorConsumed());
            }
          },
          builder: (context, state) {
            if (state is AccountLoading || state is AccountInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AccountFailure) {
              return _FailureView(
                message: state.message,
                onRetry: () => context.read<AccountBloc>().add(
                  const AccountLoadRequested(),
                ),
              );
            }

            if (state is AccountLoaded) {
              if (state.account == null) {
                return AccountRegistrationForm(
                  formKey: _formKey,
                  titleController: _titleController,
                  pinController: _pinController,
                  isSubmitting: state.isSubmitting,
                  onSubmit: _submitCreate,
                );
              }

              return _AccountDetailView(
                account: state.account!,
                formatDate: _formatDate,
                isSubmitting: state.isSubmitting,
                onChangePin: () => _openChangePinSheet(context),
                onChangeStatus: (next) => _confirmStatusChange(context, next),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Failure View (inline — small enough)
// ─────────────────────────────────────────
class _FailureView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FailureView({required this.message, required this.onRetry});

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
            AppSpacing.md.height,
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.appFonts.black14,
            ),
            AppSpacing.lg.height,
            CustomButton(text: 'Retry', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Account Detail View
// ─────────────────────────────────────────
class _AccountDetailView extends StatelessWidget {
  final dynamic account;
  final String Function(DateTime?) formatDate;
  final bool isSubmitting;
  final VoidCallback onChangePin;
  final void Function(String) onChangeStatus;

  const _AccountDetailView({
    required this.account,
    required this.formatDate,
    required this.isSubmitting,
    required this.onChangePin,
    required this.onChangeStatus,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final status = account.status.trim().toUpperCase();

    return CustomScrollView(
      slivers: [
        // ── Page header ──────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Account', style: context.appFonts.boldBlack24),
                    4.0.height,
                    Text('Manage your wallet', style: context.appFonts.grey14),
                  ],
                ),
                if (isSubmitting)
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  ),
              ],
            ),
          ),
        ),

        // ── Hero card ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
            child: AccountHeroCard(
              account: account,
              formatDate: formatDate,
              status: status,
            ),
          ),
        ),

        // ── Quick stats row ──────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
            child: _AccountStatsRow(account: account, brightness: brightness),
          ),
        ),

        // ── Security section ─────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
            child: AccountSecuritySection(
              isSubmitting: isSubmitting,
              onChangePin: onChangePin,
              brightness: brightness,
            ),
          ),
        ),

        // ── Status section ───────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            child: AccountStatusSection(
              currentStatus: status,
              isSubmitting: isSubmitting,
              onChangeStatus: onChangeStatus,
              brightness: brightness,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Quick stats row (inline — small enough)
// ─────────────────────────────────────────
class _AccountStatsRow extends StatelessWidget {
  final dynamic account;
  final Brightness brightness;

  const _AccountStatsRow({required this.account, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColors.cardColor(brightness);
    final border = AppColors.borderColor(brightness);

    return Row(
      children: [
        _StatCard(
          label: 'Currency',
          value: account.currency,
          icon: Icons.currency_exchange_rounded,
          cardBg: cardBg,
          border: border,
        ),
        10.0.width,
        _StatCard(
          label: 'Type',
          value: 'Personal',
          icon: Icons.account_balance_wallet_rounded,
          cardBg: cardBg,
          border: border,
        ),
        10.0.width,
        _StatCard(
          label: 'Access',
          value: 'Full',
          icon: Icons.verified_rounded,
          cardBg: cardBg,
          border: border,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color cardBg;
  final Color border;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.cardBg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18.w, color: AppColors.primary),
            8.0.height,
            Text(value, style: context.appFonts.boldBlack14),
            2.0.height,
            Text(label, style: context.appFonts.grey12),
          ],
        ),
      ),
    );
  }
}
