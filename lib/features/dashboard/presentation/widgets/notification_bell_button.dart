import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<NotificationBloc, NotificationState>(
      buildWhen: (p, c) => p.items != c.items || p.loading != c.loading,
      builder: (context, state) {
        final unread = state.items.where((e) => !e.isRead).length;
        return IconButton(
          tooltip: 'Notifications',
          onPressed: () => context.push(RouteEndpoints.notifications),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded, size: 26.sp),
              if (unread > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.error,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scheme.surface, width: 1.5),
                    ),
                    child: Text(
                      unread > 99 ? '99+' : '$unread',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onError,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
