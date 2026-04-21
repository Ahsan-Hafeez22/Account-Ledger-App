import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  final String subtitle;

  const DashboardHeader({
    super.key,
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
                  subtitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            child: Icon(
              Icons.people_alt_rounded,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
