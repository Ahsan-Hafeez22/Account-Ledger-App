// lib/features/notification/presentation/notification_router.dart

import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

abstract final class NotificationRouter {
  static bool canNavigate(AppNotificationEntity notification) {
    final screen = notification.data['screen']?.toString();
    switch (screen) {
      case 'TransactionDetailScreen':
        final id = notification.data['transactionId']?.toString() ?? '';
        return id.isNotEmpty;
      default:
        return false;
    }
  }

  static void navigate(
    BuildContext context,
    AppNotificationEntity notification,
  ) {
    final data = notification.data;
    final screen = data['screen']?.toString();

    switch (screen) {
      case 'TransactionDetailScreen':
        final id = data['transactionId']?.toString() ?? '';
        if (id.isEmpty) return;
        context.push(RouteEndpoints.transactionDetailPath(id));
        return;

      // ✅ Add future screens here — one place, fully controlled.
      // case 'InvoiceScreen':
      //   context.push(RouteEndpoints.invoicePath(data['invoiceId']));

      default:
        return; // Unknown screen — do nothing.
    }
  }
}
