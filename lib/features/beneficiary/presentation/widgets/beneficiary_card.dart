import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:flutter/material.dart';

class BeneficiaryCard extends StatelessWidget {
  final BeneficiaryEntity beneficiary;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool deleting;

  const BeneficiaryCard({
    super.key,
    required this.beneficiary,
    this.onTap,
    this.onDelete,
    this.deleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: scheme.surfaceContainerHighest,
                backgroundImage: (beneficiary.avatarUrl != null &&
                        beneficiary.avatarUrl!.isNotEmpty)
                    ? NetworkImage(beneficiary.avatarUrl!)
                    : null,
                child: (beneficiary.avatarUrl == null ||
                        beneficiary.avatarUrl!.isEmpty)
                    ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      beneficiary.nickname.isNotEmpty
                          ? beneficiary.nickname
                          : beneficiary.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      beneficiary.accountTitle.isNotEmpty
                          ? beneficiary.accountTitle
                          : beneficiary.accountNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      beneficiary.accountNumber,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: deleting ? null : onDelete,
                icon: deleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.delete_outline_rounded, color: scheme.error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

