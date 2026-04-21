import 'package:account_ledger/features/beneficiary/presentation/bloc/beneficiary_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBeneficiaryFlowSheet extends StatefulWidget {
  const AddBeneficiaryFlowSheet({super.key});

  @override
  State<AddBeneficiaryFlowSheet> createState() => _AddBeneficiaryFlowSheetState();
}

class _AddBeneficiaryFlowSheetState extends State<AddBeneficiaryFlowSheet> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();

  @override
  void dispose() {
    _accountCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BeneficiaryBloc>().add(
          BeneficiaryAddRequested(
            accountNumber: _accountCtrl.text.trim(),
            nickname: _nicknameCtrl.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BeneficiaryBloc, BeneficiaryState>(
      listenWhen: (p, c) =>
          p.message != c.message || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.message == 'Beneficiary added') {
          Navigator.of(context).pop(true);
          context.read<BeneficiaryBloc>().add(const BeneficiaryMessageConsumed());
        }
      },
      builder: (context, state) {
        final submitting = state.submitting;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add beneficiary',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _accountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Account number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Account number is required';
                      if (t.length < 8) return 'Enter a valid account number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nicknameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nickname',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Nickname is required';
                      return null;
                    },
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

