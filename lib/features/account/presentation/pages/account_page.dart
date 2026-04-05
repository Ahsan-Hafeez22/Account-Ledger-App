import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/core/constants/app_spacing.dart';
import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/core/extensions/sizedbox_extentions.dart';
import 'package:account_ledger/core/utils/custom_snack_bar.dart';
import 'package:account_ledger/core/utils/validators.dart';
import 'package:account_ledger/features/account/domain/entities/account_entity.dart';
import 'package:account_ledger/features/account/presentation/bloc/account_bloc.dart';
import 'package:account_ledger/shared/widgets/custom_button.dart';
import 'package:account_ledger/shared/widgets/custom_text_field.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _pinController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<AccountBloc, AccountState>(
          listenWhen: (prev, curr) {
            if (curr is AccountLoaded &&
                curr.errorMessage != null &&
                curr.errorMessage!.isNotEmpty) {
              return true;
            }
            if (prev is AccountLoaded &&
                curr is AccountLoaded &&
                prev.account == null &&
                curr.account != null) {
              return true;
            }
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
            if (state.account != null) {
              CustomSnackBar.show(
                context,
                message: 'Account created successfully',
                type: SnackBarType.success,
              );
            }
          },
          builder: (context, state) {
            if (state is AccountLoading || state is AccountInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AccountFailure) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: context.appFonts.black14,
                      ),
                      AppSpacing.lg.height,
                      CustomButton(
                        text: 'Retry',
                        onPressed: () => context.read<AccountBloc>().add(
                          const AccountLoadRequested(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (state is AccountLoaded) {
              if (state.account == null) {
                return _RegistrationForm(
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
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _RegistrationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController pinController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _RegistrationForm({
    required this.formKey,
    required this.titleController,
    required this.pinController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            200.0.height,
            Text('Create account', style: context.appFonts.boldBlack24),
            Text(
              'No wallet found. Add a title and pin code to create your account. '
              'Number, currency, and status are set on the server.',
              style: context.appFonts.grey14,
            ),
            30.0.height,
            AppSpacing.xl.height,
            CustomTextField(
              controller: titleController,
              label: 'Account title',
              hint: 'e.g. Ahsan Wallet',
              validator: (v) => Validators.required(v, 'Account title'),
            ),
            AppSpacing.xl.height,
            CustomTextField(
              controller: pinController,
              label: 'Pin code',
              hint: '4 digits',
              isPassword: true,
              pinCodeField: true,
              keyboardType: TextInputType.number,
              validator: Validators.accountPin,
            ),
            10.0.height,
            AppSpacing.xl.height,
            CustomButton(
              text: 'Create account',
              isLoading: isSubmitting,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDetailView extends StatelessWidget {
  final AccountEntity account;
  final String Function(DateTime?) formatDate;

  const _AccountDetailView({required this.account, required this.formatDate});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: [
        Text('Your wallet', style: context.appFonts.boldBlack24),
        8.0.height,
        Text('Account details', style: context.appFonts.grey14),
        AppSpacing.md.height,
        Card(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.accountTitle, style: context.appFonts.boldBlack18),
                8.0.height,
                _row(context, 'Account number', account.accountNumber),
                _row(context, 'Currency', account.currency),
                _row(context, 'Status', account.status),
                _row(context, 'Created', formatDate(account.createdAt)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(label, style: context.appFonts.grey12),
          ),
          Expanded(child: Text(value, style: context.appFonts.boldBlack12)),
        ],
      ),
    );
  }
}
