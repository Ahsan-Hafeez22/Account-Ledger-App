import 'package:account_ledger/core/dependency_injection/service_locator.dart';
import 'package:account_ledger/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:account_ledger/features/notification/data/models/app_notification_model.dart';
import 'package:account_ledger/features/notification/presentation/notification_router.dart';
import 'package:account_ledger/features/notification/presentation/widgets/empty_notifications.dart';
import 'package:account_ledger/features/notification/presentation/widgets/notification_tile.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationRemoteDatasource _remote;
  bool _loading = true;
  bool _markingAll = false;
  bool _deleting = false;
  List<AppNotificationModel> _items = const [];
  final Set<String> _selectedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _remote = sl<NotificationRemoteDatasource>();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await _remote.getNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _refresh() => _load();

  bool get _hasUnread => _items.any((e) => !e.isRead);
  bool get _selectionMode => _selectedIds.isNotEmpty;
  int get _selectedCount => _selectedIds.length;
  bool get _allSelected => _items.isNotEmpty && _selectedIds.length == _items.length;

  Future<void> _markAllRead() async {
    if (_markingAll || !_hasUnread) return;
    setState(() => _markingAll = true);
    final now = DateTime.now();
    // Optimistic UI update.
    setState(() {
      _items = _items.map((e) => e.isRead ? e : e.copyWith(readAt: now)).toList();
    });
    try {
      await _remote.markAllRead();
    } catch (_) {
      // If server fails, we keep UI optimistic; next refresh will reconcile.
    } finally {
      if (mounted) {
        setState(() => _markingAll = false);
      }
    }
  }

  void _toggleSelection(AppNotificationModel n) {
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

  void _selectAll() {
    setState(() {
      _selectedIds
        ..clear()
        ..addAll(_items.map((e) => e.id));
    });
  }

  Future<void> _deleteSelected() async {
    if (_deleting || _selectedIds.isEmpty) return;
    final ids = _selectedIds.toList(growable: false);
    final before = _items;

    setState(() {
      _deleting = true;
      _items = _items.where((e) => !_selectedIds.contains(e.id)).toList();
      _selectedIds.clear();
    });

    try {
      await _remote.deleteMany(ids);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted ${ids.length} notification(s)')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = before;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _deleteOne(AppNotificationModel n) async {
    if (_deleting) return;
    final before = _items;
    setState(() {
      _deleting = true;
      _items = _items.where((e) => e.id != n.id).toList();
      _selectedIds.remove(n.id);
    });
    try {
      await _remote.deleteOne(n.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = before;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Delete failed. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _open(AppNotificationModel n) async {
    if (_selectionMode) {
      _toggleSelection(n);
      return;
    }
    // Mark as read locally first (so when user pops back, it's already read).
    if (!n.isRead) {
      final now = DateTime.now();
      setState(() {
        _items = _items
            .map((e) => e.id == n.id ? e.copyWith(readAt: now) : e)
            .toList();
      });
      try {
        await _remote.markRead(n.id);
      } catch (_) {
        // Keep optimistic UI; refresh later will reconcile.
      }
    }
    if (!mounted) return;
    NotificationRouter.navigate(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
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
              tooltip: _allSelected ? 'Clear all' : 'Select all',
              onPressed: _allSelected ? _clearSelection : _selectAll,
              icon: Icon(_allSelected ? Icons.select_all_rounded : Icons.done_all_rounded),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: _deleting ? null : _deleteSelected,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ] else if (_hasUnread)
            TextButton(
              onPressed: _markingAll ? null : _markAllRead,
              child: _markingAll
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? const EmptyNotifications()
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = _items[index];
                      final tile = NotificationTile(
                        notification: n,
                        selectionMode: _selectionMode,
                        selected: _selectedIds.contains(n.id),
                        onLongPress: () => _toggleSelection(n),
                        onTap: _selectionMode
                            ? () => _toggleSelection(n)
                            : (NotificationRouter.canNavigate(n) ? () => _open(n) : null),
                      );
                      if (_selectionMode) return tile;
                      return Dismissible(
                        key: ValueKey('notif_${n.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (_) async => true,
                        onDismissed: (_) => _deleteOne(n),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 18),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(Icons.delete_rounded, color: scheme.onErrorContainer),
                        ),
                        child: tile,
                      );
                    },
                  ),
      ),
    );
  }
}

