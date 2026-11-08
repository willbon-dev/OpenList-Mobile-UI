import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/site.dart';
import '../../generated/l10n.dart';
import '../../services/auth_service.dart';

/// 目标目录选择对话框（移动/复制用）：逐级浏览，返回选中的目录路径。
Future<String?> showPathPickerDialog(
  BuildContext context, {
  required String title,
  required String initialDir,
  required Site site,
}) async {
  return Get.dialog<String>(
    _PathPickerDialog(title: title, initialDir: initialDir, site: site),
    barrierDismissible: false,
  );
}

class _PathPickerDialog extends StatefulWidget {
  final String title;
  final String initialDir;
  final Site site;

  const _PathPickerDialog({
    required this.title,
    required this.initialDir,
    required this.site,
  });

  @override
  State<_PathPickerDialog> createState() => _PathPickerDialogState();
}

class _PathPickerDialogState extends State<_PathPickerDialog> {
  late String _dir;
  List<_PickerEntry> _dirs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dir = widget.initialDir;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dirs = await Get.find<AuthService>()
          .execute(widget.site, (c) => c.fsDirs(_dir));
      dirs.sort((a, b) => a.name.compareTo(b.name));
      setState(() {
        _dirs = dirs.map((d) => _PickerEntry(d.name)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _enter(String name) {
    setState(() {
      _dir = _join(_dir, name);
    });
    _load();
  }

  void _up() {
    if (_dir == '/' || _dir.isEmpty) return;
    final p = _dir.substring(0, _dir.length - 1);
    final idx = p.lastIndexOf('/');
    setState(() {
      _dir = idx <= 0 ? '/' : p.substring(0, idx + 1);
    });
    _load();
  }

  static String _join(String dir, String name) =>
      dir.endsWith('/') ? '$dir$name' : '$dir/$name';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _dir == '/' ? null : _up,
                  icon: const Icon(Icons.arrow_upward),
                  tooltip: S.current.rootDir,
                ),
                Expanded(
                  child: Text(
                    _dir,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _dirs.isEmpty
                          ? Center(child: Text(S.current.emptyList))
                          : ListView.builder(
                              itemCount: _dirs.length,
                              itemBuilder: (context, i) {
                                final entry = _dirs[i];
                                return ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.folder),
                                  title: Text(entry.name),
                                  onTap: () => _enter(entry.name),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () => Get.back(result: _dir),
          child: Text(S.current.confirm),
        ),
      ],
    );
  }
}

class _PickerEntry {
  final String name;
  const _PickerEntry(this.name);
}
