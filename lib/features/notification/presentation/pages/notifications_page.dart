import 'package:account_ledger/features/notification/domain/entities/app_notification_entity.dart';
import 'package:account_ledger/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:account_ledger/features/notification/presentation/notification_router.dart';
import 'package:account_ledger/features/notification/presentation/widgets/empty_notifications.dart';
import 'package:account_ledger/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _markingSelected = false;
  bool _deleting = false;
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    context.read<NotificationBloc>().add(NotificationsLoadRequested());

    super.initState();
  }

  Future<void> _refresh() async {
    context.read<NotificationBloc>().add(const NotificationsRefreshRequested());
  }

  bool get _selectionMode => _selectedIds.isNotEmpty;
  int get _selectedCount => _selectedIds.length;
  bool _allSelected(List<AppNotificationEntity> items) =>
      items.isNotEmpty && _selectedIds.length == items.length;

  bool _selectedHasUnread(List<AppNotificationEntity> items) =>
      items.any((e) => _selectedIds.contains(e.id) && !e.isRead);

  /// Marks only the selected notifications as read.
  Future<void> _markSelectedRead(List<AppNotificationEntity> items) async {
    if (_markingSelected || !_selectedHasUnread(items)) return;
    final ids = _selectedIds.toList(growable: false);
    setState(() {
      _markingSelected = true;
      _selectedIds.clear();
    });
    try {
      for (final id in ids) {
        context.read<NotificationBloc>().add(NotificationMarkReadRequested(id));
      }
    } finally {
      if (mounted) setState(() => _markingSelected = false);
    }
  }

  void _toggleSelection(AppNotificationEntity n) {
    setState(() {
      if (_selectedIds.contains(n.id)) {
        _selectedIds.remove(n.id);
      } else {
        _selectedIds.add(n.id);
      }
    });
  }

  void _clearSelection() {
    if (_selectedIds.isEmpty) return;
    setState(() => _selectedIds.clear());
  }

  Future<void> _deleteSelected() async {
    if (_deleting || _selectedIds.isEmpty) return;
    final ids = _selectedIds.toList(growable: false);

    setState(() {
      _deleting = true;
      _selectedIds.clear();
    });

    try {
      context.read<NotificationBloc>().add(
        NotificationsDeleteManyRequested(ids),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _open(AppNotificationEntity n) async {
    if (_selectionMode) {
      _toggleSelection(n);
      return;
    }

    // Always allow a notification to be marked as read on tap (including
    // announcements that don't navigate anywhere).
    if (!n.isRead) {
      context.read<NotificationBloc>().add(NotificationMarkReadRequested(n.id));
    }
    if (!mounted) return;
    if (NotificationRouter.canNavigate(n)) {
      NotificationRouter.navigate(context, n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<NotificationBloc, NotificationState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage && c.errorMessage != null,
      listener: (context, state) {
        final msg = state.errorMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      },
      builder: (context, state) {
        final items = state.items;
        final hasUnread = state.hasUnread;
        final markingAll = state.markingAll;
        final allSelected = _allSelected(items);
        final selectedHasUnread = _selectedHasUnread(items);

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            leading: _selectionMode
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: _clearSelection,
                  )
                : null,
            title: _selectionMode
                ? Text('$_selectedCount selected')
                : const Text('Notifications'),
            actions: [
              if (_selectionMode) ...[
                IconButton(
                  tooltip: allSelected ? 'Deselect all' : 'Select all',
                  onPressed: () {
                    setState(() {
                      if (allSelected) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds
                          ..clear()
                          ..addAll(items.map((e) => e.id));
                      }
                    });
                  },
                  icon: Icon(
                    allSelected
                        ? Icons.deselect_rounded
                        : Icons.select_all_rounded,
                  ),
                ),
                if (selectedHasUnread)
                  IconButton(
                    tooltip: 'Mark selected as read',
                    onPressed: (_markingSelected || markingAll)
                        ? null
                        : () => _markSelectedRead(items),
                    icon: _markingSelected
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: scheme.primary,
                            ),
                          )
                        : const Icon(Icons.done_all_rounded),
                  ),
                IconButton(
                  tooltip: 'Delete selected',
                  onPressed: _deleting ? null : _deleteSelected,
                  icon: _deleting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.error,
                          ),
                        )
                      : const Icon(Icons.delete_outline_rounded),
                ),
              ] else if (hasUnread)
                TextButton(
                  onPressed: (markingAll || _markingSelected)
                      ? null
                      : () => context.read<NotificationBloc>().add(
                          const NotificationsMarkAllReadRequested(),
                        ),
                  child: markingAll
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        )
                      : const Text('Mark all read'),
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                ? const EmptyNotifications()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      final canNav = NotificationRouter.canNavigate(n);

                      final tile = NotificationTile(
                        notification: n,
                        selectionMode: _selectionMode,
                        selected: _selectedIds.contains(n.id),
                        navigable: canNav,
                        onLongPress: () => _toggleSelection(n),
                        onTap: _selectionMode
                            ? () => _toggleSelection(n)
                            : () => _open(n),
                      );

                      if (_selectionMode) return tile;

                      return _SwipeToDelete(
                        key: ValueKey('notif_${n.id}'),
                        onDismissed: () => context.read<NotificationBloc>().add(
                          NotificationDeleteOneRequested(n.id),
                        ),
                        child: tile,
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

/// A custom swipe-to-delete wrapper that slides the ENTIRE card (including
/// its background) off screen, revealing a red delete background beneath it.
class _SwipeToDelete extends StatefulWidget {
  final VoidCallback onDismissed;
  final Widget child;

  const _SwipeToDelete({
    super.key,
    required this.onDismissed,
    required this.child,
  });

  @override
  State<_SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<_SwipeToDelete>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragOffset = 0;
  bool _dismissed = false;

  static const double _dismissThreshold = 0.45; // 45% of width triggers dismiss

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dismissed) return;
    final newOffset = (_dragOffset + details.delta.dx).clamp(
      -double.infinity,
      0.0,
    );
    setState(() => _dragOffset = newOffset);
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (_dismissed) return;

    final width = context.size?.width ?? 300;
    final ratio = _dragOffset.abs() / width;

    final velocity = details.primaryVelocity ?? 0;

    if (ratio >= _dismissThreshold || velocity < -800) {
      // Animate the card fully off screen.
      setState(() => _dismissed = true);
      final remaining = width + _dragOffset; // how far left to go
      _controller.duration = Duration(
        milliseconds: (remaining / 800 * 1000).clamp(150, 300).toInt(),
      );
      await _controller.forward();
      widget.onDismissed();
    } else {
      // Snap back.
      final startOffset = _dragOffset;
      _controller.duration = const Duration(milliseconds: 250);
      _controller.reset();
      // Animate back to 0
      final animation = Tween<double>(begin: startOffset, end: 0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      animation.addListener(
        () => setState(() => _dragOffset = animation.value),
      );
      await _controller.forward();
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width - 32; // account for padding

    // How far the card has been dragged (0..1)
    final ratio = (_dragOffset.abs() / width).clamp(0.0, 1.0);
    // Additional slide when dismissed
    final dismissSlide = _dismissed ? -width * _controller.value : 0.0;
    final totalSlide = _dragOffset + dismissSlide;

    return SizedBox(
      height: null, // let child size itself
      child: Stack(
        children: [
          // Background (delete indicator) — always behind the card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: AnimatedOpacity(
                opacity: (ratio * 2).clamp(0.0, 1.0),
                duration: Duration.zero,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.delete_rounded, color: scheme.onErrorContainer),
                  ],
                ),
              ),
            ),
          ),
          // The card itself — slides with drag
          Transform.translate(
            offset: Offset(totalSlide, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
