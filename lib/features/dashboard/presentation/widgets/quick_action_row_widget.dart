import 'package:flutter/material.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  const QuickActionsRow({
    super.key,
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
