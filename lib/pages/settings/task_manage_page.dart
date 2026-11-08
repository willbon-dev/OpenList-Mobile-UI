import 'package:flutter/material.dart';

import '../../core/models/task.dart';
import '../../core/models/site.dart';
import '../../generated/l10n.dart';
import '../../services/auth_service.dart';

/// 服务器任务管理：离线下载 / 上传 / 复制 / 移动 / 解压。
class TaskManagePage extends StatefulWidget {
  final Site site;

  const TaskManagePage({super.key, required this.site});

  @override
  State<TaskManagePage> createState() => _TaskManagePageState();
}

class _TaskManagePageState extends State<TaskManagePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl =
      TabController(length: TaskCategory.values.length, vsync: this);
  bool _loading = true;
  String? _error;
  List<TaskInfo> _undone = [];
  List<TaskInfo> _done = [];
  DateTime? _lastLoad;

  @override
  void initState() {
    super.initState();
    _tabCtrl.addListener(_onTabChanged);
    _load();
  }

  void _onTabChanged() {
    if (!_tabCtrl.indexIsChanging) _load();
  }

  @override
  void dispose() {
    _tabCtrl.removeListener(_onTabChanged);
    _tabCtrl.dispose();
    super.dispose();
  }

  TaskCategory get _current => TaskCategory.values[_tabCtrl.index];

  Future<void> _load() async {
    final cat = _current;
    try {
      final undone = await AuthService.to
          .execute(widget.site, (c) => c.taskList(cat.apiCat, done: false));
      final done = await AuthService.to
          .execute(widget.site, (c) => c.taskList(cat.apiCat, done: true));
      if (!mounted) return;
      setState(() {
        _undone = undone;
        _done = done;
        _loading = false;
        _error = null;
        _lastLoad = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _taskAction(TaskInfo t, String action) async {
    try {
      await AuthService.to
          .execute(widget.site, (c) => c.taskAction(_current.apiCat, action, t.id));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.current.operationFailed(e.toString())),
          duration: const Duration(seconds: 3)));
    }
  }

  Future<void> _clear(String action, String label) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(label),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(S.current.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(S.current.confirm)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AuthService.to
          .execute(widget.site, (c) => c.taskClear(_current.apiCat, action));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S.current.operationFailed(e.toString())),
          duration: const Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.taskManage),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          PopupMenuButton<String>(
            onSelected: (action) => _clear(action, action == 'clear_succeeded' ? S.current.clearSucceeded : S.current.clearFailed),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'clear_succeeded',
                  child: Text(S.current.clearSucceeded)),
              PopupMenuItem(
                  value: 'clear_errored',
                  child: Text(S.current.clearFailed)),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: [
            for (final cat in TaskCategory.values)
              Tab(text: '${cat.label}'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        OutlinedButton(
                            onPressed: _load, child: Text(S.current.retry)),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      if (_undone.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Text(S.current.undoneTasks,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                        ),
                        for (final t in _undone)
                          _TaskTile(
                            task: t,
                            onRetry: () => _taskAction(t, 'retry'),
                            onCancel: () => _taskAction(t, 'cancel'),
                            onDelete: () => _taskAction(t, 'delete'),
                          ),
                      ],
                      if (_done.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Text(S.current.doneTasks,
                              style: Theme.of(context).textTheme.titleSmall),
                        ),
                        for (final t in _done)
                          _TaskTile(
                            task: t,
                            onDelete: () => _taskAction(t, 'delete'),
                          ),
                      ],
                      if (_undone.isEmpty && _done.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(48),
                          child: Center(child: Text(S.current.taskEmpty)),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                      ),
                    ],
                  ),
                ),
              );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskInfo task;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const _TaskTile({
    required this.task,
    this.onRetry,
    this.onCancel,
    this.onDelete,
  });

  bool get _isDone {
    final s = task.state;
    return s == 'succeeded' || s == 'failed' || s == 'canceled';
  }

  @override
  Widget build(BuildContext context) {
    final failed =
        task.state == 'failed' || task.state == 'errored';
    return ListTile(
      leading: Icon(
        task.state == 'succeeded'
            ? Icons.check_circle
            : failed
                ? Icons.error
                : Icons.timelapse,
        color: task.state == 'succeeded'
            ? Colors.green
            : failed
                ? Colors.red
                : Theme.of(context).colorScheme.primary,
      ),
      title: Text(task.name,
          maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text('${taskStateLabel(task.state)}'
              '${task.error.isEmpty ? '' : ' · ${task.error}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  color: failed
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant)),
          if (!_isDone) ...[
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: (task.progress / 100).clamp(0.0, 1.0),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isDone && onRetry != null &&
              (failed || task.state == 'waiting_retry' || task.state == 'before_retry'))
            IconButton(
              tooltip: S.current.retry,
              icon: const Icon(Icons.refresh),
              onPressed: onRetry,
            ),
          if (!_isDone && onCancel != null &&
              (task.state == 'pending' || task.state == 'running' ||
                  task.state == 'waiting_retry' || task.state == 'before_retry'))
            IconButton(
              tooltip: S.current.cancel,
              icon: const Icon(Icons.close),
              onPressed: onCancel,
            ),
          if (onDelete != null && _isDone)
            IconButton(
              tooltip: S.current.delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
        ],
      ),
      isThreeLine: true,
    );
  }
}
