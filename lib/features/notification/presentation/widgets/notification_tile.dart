import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationTile extends StatelessWidget {
  final AppNotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selectionMode;
  final bool selected;

  /// Whether this notification navigates to a screen when tapped.
  /// Non-navigable tiles will not mark themselves as read on tap.
  final bool navigable;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
    this.navigable = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isRead = notification.isRead;

    final icon = _iconForType(notification.type);
    final iconBg = isRead
        ? scheme.surfaceContainerHighest
        : scheme.primaryContainer;
    final iconFg = isRead ? scheme.onSurfaceVariant : scheme.onPrimaryContainer;

    final time = DateFormat(
      'MMM d, h:mm a',
    ).format(notification.createdAt.toLocal());

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        // Non-navigable notifications show a slightly different splash to
        // signal they are not interactive in the conventional sense.
        splashColor: navigable
            ? scheme.primary.withValues(alpha: 0.08)
            : scheme.onSurface.withValues(alpha: 0.04),
        highlightColor: navigable
            ? scheme.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? scheme.secondaryContainer
                : (isRead ? scheme.surface : scheme.surfaceContainerLow),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? scheme.secondary.withValues(alpha: 0.65)
                  : scheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconFg),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: isRead
                                      ? FontWeight.w600
                                      : FontWeight.w800,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    // if (!selectionMode && !navigable) ...[
                    //   const SizedBox(height: 6),
                    //   Text(
                    //     'Announcement',
                    //     style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    //       color: scheme.onSurfaceVariant,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
              // Right-side indicator
              if (selectionMode) ...[
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? scheme.secondary : scheme.onSurfaceVariant,
                ),
              ] else if (!isRead) ...[
                const SizedBox(width: 10),
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'MONEY_SENT':
        return Icons.north_east_rounded;
      case 'MONEY_RECEIVED':
        return Icons.south_west_rounded;
      case 'ACCOUNT_CREATED':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
