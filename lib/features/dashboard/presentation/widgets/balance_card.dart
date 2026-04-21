import 'package:account_ledger/core/constants/app_fonts.dart';
import 'package:account_ledger/features/dashboard/presentation/bloc/balance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final String currency;
  const BalanceCard({super.key, required this.currency});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fmt = NumberFormat.currency(symbol: '$currency ');

    return BlocBuilder<BalanceBloc, BalanceState>(
      builder: (context, state) {
        final balanceText = state.balance == null
            ? '—'
            : fmt.format(state.balance);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.secondaryContainer,
                scheme.secondaryContainer.withValues(alpha: 0.65),
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
                      'Available balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSecondaryContainer.withValues(alpha: 0.85),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      balanceText,
                      style: context.appFonts.boldBlack24.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        state.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.error,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh',
                onPressed: state.loading
                    ? null
                    : () => context.read<BalanceBloc>().add(const BalanceRefreshRequested()),
                icon: state.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.refresh_rounded, color: scheme.onSecondaryContainer),
              ),
            ],
          ),
        );
      },
    );
  }
}

