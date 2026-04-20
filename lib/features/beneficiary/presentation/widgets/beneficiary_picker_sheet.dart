import 'package:account_ledger/features/beneficiary/domain/entities/beneficiary_entity.dart';
import 'package:flutter/material.dart';

class BeneficiaryPickerSheet extends StatelessWidget {
  final List<BeneficiaryEntity> items;
  const BeneficiaryPickerSheet({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose beneficiary',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Text(
                  'No beneficiaries yet. Add one from Dashboard.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final b = items[index];
                    return Material(
                      color: scheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: scheme.surfaceContainerHighest,
                          backgroundImage: (b.avatarUrl != null && b.avatarUrl!.isNotEmpty)
                              ? NetworkImage(b.avatarUrl!)
                              : null,
                          child: (b.avatarUrl == null || b.avatarUrl!.isEmpty)
                              ? Icon(Icons.person, color: scheme.onSurfaceVariant)
                              : null,
                        ),
                        title: Text(
                          b.nickname.isNotEmpty ? b.nickname : b.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${b.accountTitle.isNotEmpty ? b.accountTitle : ''}\n${b.accountNumber}',
                          maxLines: 2,
                        ),
                        isThreeLine: true,
                        onTap: () => Navigator.of(context).pop(b),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

