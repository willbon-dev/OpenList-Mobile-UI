import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/models/driver_info.dart';
import '../../core/models/site.dart';
import '../../core/models/storage.dart';
import '../../core/utils/driver_field_names.dart';
import '../../core/utils/driver_names.dart';
import '../../generated/l10n.dart';
import '../../services/auth_service.dart';
import 'qr_scan_page.dart';

/// 存储管理：列出/挂载/编辑/启停/删除服务器存储（需管理员账号）。
class StorageManagePage extends StatefulWidget {
  final Site site;

  const StorageManagePage({super.key, required this.site});

  @override
  State<StorageManagePage> createState() => _StorageManagePageState();
}

class _StorageManagePageState extends State<StorageManagePage> {
  bool _loading = true;
  String? _error;
  List<StorageInfo> _storages = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await AuthService.to
          .execute(widget.site, (c) => c.adminListStorages());
      if (!mounted) return;
      setState(() => _storages = list);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmDelete(StorageInfo s) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text(S.current.deleteStorage),
      content: Text(S.current.deleteStorageConfirm(s.mountPath)),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: Text(S.current.cancel)),
        FilledButton(
            onPressed: () => Get.back(result: true),
            child: Text(S.current.confirm)),
      ],
    ));
    if (ok != true) return;
    try {
      await AuthService.to
          .execute(widget.site, (c) => c.adminDeleteStorage(s.id));
      Get.showSnackbar(GetSnackBar(
          message: S.current.deleteSuccess,
          duration: const Duration(seconds: 2)));
      _load();
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
          message: S.current.operationFailed(e.toString()),
          duration: const Duration(seconds: 3)));
    }
  }

  Future<void> _toggleEnabled(StorageInfo s) async {
    try {
      await AuthService.to.execute(
          widget.site, (c) => c.adminSetStorageEnabled(s.id, s.disabled));
      _load();
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
          message: S.current.operationFailed(e.toString()),
          duration: const Duration(seconds: 3)));
    }
  }

  Future<void> _openEditor({StorageInfo? existing}) async {
    final driverNames = await AuthService.to
        .execute(widget.site, (c) => c.adminDriverNames());
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => _StorageEditPage(
        site: widget.site,
        existing: existing,
        driverNames: driverNames,
      ),
    ));
    if (changed == true) _load();
  }

  /// 扫码挂载：扫描存储配置二维码后进入预填好的编辑页
  Future<void> _scanMount() async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (scanned == null || scanned.isEmpty || !mounted) return;
    try {
      final decoded = jsonDecode(scanned);
      if (decoded is! Map<String, dynamic> || !decoded.containsKey('driver')) {
        throw const FormatException('not a storage config');
      }
      final existing = StorageInfo(decoded);
      await _openEditor(existing: existing);
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
          message: S.current.qrInvalid,
          duration: const Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.storageManage),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'scan-mount',
            onPressed: _scanMount,
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'mount',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add),
            label: Text(S.current.mountStorage),
          ),
        ],
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
                            onPressed: _load,
                            child: Text(S.current.retry)),
                      ],
                    ),
                  ),
                )
              : _storages.isEmpty
                  ? Center(child: Text(S.current.storageEmpty))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        itemCount: _storages.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final s = _storages[i];
                          return ListTile(
                            leading: Icon(
                              s.disabled
                                  ? Icons.storage_outlined
                                  : Icons.storage,
                              color: s.disabled
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.primary,
                            ),
                            title: Text(s.mountPath,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              '${driverDisplayName(s.driver)}'
                              '${s.status.isEmpty ? '' : ' · ${s.status}'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Switch(
                              value: !s.disabled,
                              onChanged: (_) => _toggleEnabled(s),
                            ),
                            onTap: () => _openEditor(existing: s),
                            onLongPress: () => _confirmDelete(s),
                          );
                        },
                      ),
                    ),
    );
  }
}

/// 挂载/编辑存储。编辑时 [existing] 非空。
/// 表单字段由驱动定义（/api/admin/driver/info）动态生成，覆盖全部配置项。
class _StorageEditPage extends StatefulWidget {
  final Site site;
  final StorageInfo? existing;
  final List<String> driverNames;

  const _StorageEditPage({
    required this.site,
    required this.existing,
    required this.driverNames,
  });

  @override
  State<_StorageEditPage> createState() => _StorageEditPageState();
}

class _StorageEditPageState extends State<_StorageEditPage> {
  late String _driver;
  late final TextEditingController _mountCtrl;
  late final TextEditingController _remarkCtrl;
  late final TextEditingController _orderCtrl;

  /// bool / select 字段值（text/number 字段值保存在控制器中）
  Map<String, dynamic> _values = {};

  /// 动态字段的文本控制器（按字段名），避免每次重建导致输入光标跳动
  final Map<String, TextEditingController> _ctrls = {};

  /// 驱动定义（驱动选择后拉取）
  DriverInfo? _driverInfo;

  bool _loadingInfo = false;
  bool _saving = false;
  bool _additionalExpanded = false;

  /// common 中由专用控件处理的字段，其余 common 字段动态渲染
  static const _dedicatedCommon = {'mount_path', 'remark', 'order'};

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _driver = existing?.driver ?? 'Local';
    _mountCtrl = TextEditingController(text: existing?.mountPath ?? '/');
    _remarkCtrl = TextEditingController(text: existing?.remark ?? '');
    _orderCtrl = TextEditingController(
        text: (existing?.raw['order'] ?? 0).toString());
    _values = _initialValues();
    _fetchDriverInfo();
  }

  /// 初始表单值：编辑时优先已有值（additional 取 addition，
  /// common 取 raw），新建用驱动定义默认值
  Map<String, dynamic> _initialValues() {
    final values = <String, dynamic>{};
    final existing = widget.existing;
    final addition = existing?.additionMap ?? const <String, dynamic>{};
    final info = _driverInfo;
    if (info == null) return values;
    for (final item in [...info.common, ...info.additional]) {
      final isAdditional =
          info.additional.any((i) => i.name == item.name);
      if (isAdditional && addition.containsKey(item.name)) {
        values[item.name] = addition[item.name];
      } else if (existing != null && existing.raw.containsKey(item.name)) {
        values[item.name] = existing.raw[item.name];
      } else {
        values[item.name] = _parseDefault(item);
      }
    }
    return values;
  }

  /// 按字段类型解析默认值字符串
  dynamic _parseDefault(DriverItemDef item) {
    final d = item.default_;
    switch (item.type) {
      case 'bool':
        return d == 'true';
      case 'number':
        return num.tryParse(d) ?? 0;
      default:
        return d;
    }
  }

  Future<void> _fetchDriverInfo() async {
    setState(() => _loadingInfo = true);
    try {
      final info = await AuthService.to
          .execute(widget.site, (c) => c.adminDriverInfo(_driver));
      if (!mounted) return;
      setState(() {
        _driverInfo = info;
        _resetForm(info);
        _loadingInfo = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingInfo = false);
    }
  }

  /// 表单重置：值按驱动定义/已有配置重建，文本控制器全部换新
  void _resetForm(DriverInfo info) {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _ctrls.clear();
    _values = _initialValues();
    for (final item in [...info.common, ...info.additional]) {
      if (item.type == 'bool' || item.type == 'select') continue;
      if (_dedicatedCommon.contains(item.name)) continue;
      _ctrls[item.name] = TextEditingController(
          text: _values[item.name]?.toString() ?? '');
    }
    // 含必填项或字段较少时默认展开高级配置
    _additionalExpanded = info.additional.any((i) => i.required) ||
        info.additional.length <= 8;
  }

  void _switchDriver(String driver) {
    if (driver == _driver) return;
    setState(() {
      _driver = driver;
      _driverInfo = null;
    });
    _fetchDriverInfo();
  }

  /// 取字段当前值并按类型归一化（文本类从控制器读取）
  dynamic _normalized(DriverItemDef item) {
    switch (item.type) {
      case 'bool':
        final v = _values[item.name];
        return v == true || v == 'true';
      case 'select':
        return _values[item.name]?.toString() ?? '';
      default:
        final raw =
            _ctrls[item.name]?.text ?? _values[item.name]?.toString() ?? '';
        if (item.type == 'number') return num.tryParse(raw) ?? 0;
        return raw;
    }
  }

  List<DriverItemDef> get _dynamicCommonItems => (_driverInfo?.common ?? [])
      .where((item) => !_dedicatedCommon.contains(item.name))
      .toList();

  /// 当前配置整体 JSON（二维码导出用）
  String _configJson() {
    final common = <String, dynamic>{};
    for (final item in _dynamicCommonItems) {
      common[item.name] = _normalized(item);
    }
    final addition = <String, dynamic>{};
    for (final item in _driverInfo?.additional ?? const <DriverItemDef>[]) {
      addition[item.name] = _normalized(item);
    }
    return jsonEncode({
      'mount_path': _mountCtrl.text.trim(),
      'driver': _driver,
      'remark': _remarkCtrl.text.trim(),
      ...common,
      'addition': addition,
    });
  }

  /// 导入值应用到表单：bool/select 进 _values，文本进控制器
  void _applyImported(Iterable<DriverItemDef> items, Map<String, dynamic> data) {
    for (final item in items) {
      if (!data.containsKey(item.name)) continue;
      final v = data[item.name];
      if (item.type == 'bool' || item.type == 'select') {
        _values[item.name] = v;
      } else if (_ctrls.containsKey(item.name)) {
        _ctrls[item.name]!.text = v?.toString() ?? '';
      }
    }
  }

  /// 二维码扫描导入：含 driver 的整体配置，否则视为 addition 配置合并
  Future<void> _scanImport() async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanPage()),
    );
    if (scanned == null || scanned.isEmpty || !mounted) return;
    try {
      final decoded = jsonDecode(scanned);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('not an object');
      }
      if (decoded.containsKey('driver')) {
        final storage = StorageInfo(decoded);
        setState(() {
          _driver = storage.driver;
          _mountCtrl.text = storage.mountPath;
          _remarkCtrl.text = storage.remark;
        });
        await _fetchDriverInfo();
        // 拉取定义后用扫码数据覆盖默认值
        setState(() {
          _applyImported(_driverInfo?.additional ?? const [], storage.additionMap);
          _applyImported(_dynamicCommonItems, storage.raw);
        });
      } else {
        setState(() {
          _applyImported(_driverInfo?.additional ?? const [], decoded);
        });
      }
      Get.showSnackbar(GetSnackBar(
          message: S.current.importSuccess,
          duration: const Duration(seconds: 2)));
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
          message: S.current.qrInvalid,
          duration: const Duration(seconds: 3)));
    }
  }

  /// 驱动选择底部弹层：有动画、支持搜索、显示中文名
  Future<void> _pickDriver() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _DriverPickerSheet(
        drivers: widget.driverNames,
        current: _driver,
      ),
    );
    if (picked != null && picked != _driver) {
      _switchDriver(picked);
    }
  }

  Future<void> _save() async {
    final mount = _mountCtrl.text.trim();
    if (mount.isEmpty || !mount.startsWith('/')) {
      Get.showSnackbar(GetSnackBar(
          message: S.current.mountPathInvalid,
          duration: const Duration(seconds: 2)));
      return;
    }

    final body = widget.existing?.raw != null
        ? Map<String, dynamic>.from(widget.existing!.raw)
        : <String, dynamic>{
            'cache_expiration': 30,
            'order': 0,
            'enable_sign': false,
            'web_proxy': false,
            'webdav_policy': '302_redirect_proxy',
          };
    body['mount_path'] = mount;
    body['driver'] = _driver;
    body['remark'] = _remarkCtrl.text.trim();
    body['order'] = int.tryParse(_orderCtrl.text.trim()) ?? 0;
    for (final item in _dynamicCommonItems) {
      body[item.name] = _normalized(item);
    }
    final addition = <String, dynamic>{};
    for (final item in _driverInfo?.additional ?? const <DriverItemDef>[]) {
      addition[item.name] = _normalized(item);
    }
    body['addition'] = jsonEncode(addition);

    setState(() => _saving = true);
    try {
      await AuthService.to.execute(widget.site, (c) {
        return widget.existing != null
            ? c.adminUpdateStorage(body)
            : c.adminCreateStorage(body);
      });
      if (!mounted) return;
      Get.showSnackbar(GetSnackBar(
          message: widget.existing != null
              ? S.current.saveSuccess
              : S.current.mountSuccess,
          duration: const Duration(seconds: 2)));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      // create 时 root 目录非法：服务端会先建记录再报初始化失败，
      // 记录仍存在，可返回列表后编辑修正
      Get.showSnackbar(GetSnackBar(
          message: S.current.operationFailed(e.toString()),
          duration: const Duration(seconds: 4)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _driverInfo;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null
            ? S.current.editStorage
            : S.current.mountStorage),
        actions: [
          IconButton(
              tooltip: S.current.qrImport,
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _scanImport),
          IconButton(
              tooltip: S.current.qrExport,
              icon: const Icon(Icons.qr_code),
              onPressed: info == null ? null : _showExportQr),
        ],
        bottom: _saving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // 基础信息：驱动 / 挂载路径 / 备注 / 排序
          _section(S.current.basicInfo, icon: Icons.folder_open, children: [
            _driverPicker(),
            TextField(
              controller: _mountCtrl,
              decoration: InputDecoration(
                labelText: S.current.mountPath,
                hintText: '/local',
                helperText:
                    fieldHelpZh('mount_path', _helpOf(info, 'mount_path')),
                helperMaxLines: 3,
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _remarkCtrl,
              decoration: InputDecoration(
                labelText: S.current.remark,
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _orderCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: fieldDisplayName('order'),
                helperText: fieldHelpZh('order', 'use to sort'),
                helperMaxLines: 3,
                border: const OutlineInputBorder(),
              ),
            ),
          ]),
          if (_loadingInfo) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
          if (info != null) ...[
            const SizedBox(height: 16),
            // 常规设置：缓存 / 代理 / WebDAV / 排序方式等
            _section(S.current.generalSettings,
                icon: Icons.tune,
                children:
                    _fieldsFor(info.common.where((i) => !_dedicatedCommon.contains(i.name)))),
            const SizedBox(height: 16),
            // 驱动专属配置：按驱动动态生成，可折叠
            _additionalSection(info),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: FilledButton(
          style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48)),
          onPressed: info == null || _loadingInfo || _saving
              ? null
              : _save,
          child: _saving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.onPrimary))
              : Text(S.current.save),
        ),
      ),
    );
  }

  /// 驱动选择器（底部弹层 + 动画 + 中文显示）
  Widget _driverPicker() {
    return InkWell(
      onTap: _pickDriver,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: S.current.driver,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(driverDisplayName(_driver),
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  /// 分组卡片：标题 + 统一间距的字段列表
  Widget _section(String title,
      {IconData? icon, List<Widget> children = const []}) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Text(title, style: theme.textTheme.titleSmall),
            ]),
            const SizedBox(height: 12),
            ..._withGaps(children),
          ],
        ),
      ),
    );
  }

  /// 驱动专属配置（可折叠卡片），含必填项或字段较少时默认展开
  Widget _additionalSection(DriverInfo info) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: .5)),
      ),
      child: ExpansionTile(
        key: ValueKey(_driver),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        initiallyExpanded: _additionalExpanded,
        onExpansionChanged: (v) => _additionalExpanded = v,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(S.current.driverSpecific,
            style: theme.textTheme.titleSmall),
        subtitle: Text(
          '${driverDisplayName(_driver)} · ${S.current.additionalItems(info.additional.length)}',
          style: theme.textTheme.bodySmall,
        ),
        children: _withGaps(_fieldsFor(info.additional)),
      ),
    );
  }

  List<Widget> _withGaps(List<Widget> children) => [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          children[i],
        ]
      ];

  String _helpOf(DriverInfo? info, String name) {
    if (info == null) return '';
    for (final item in info.common) {
      if (item.name == name && item.help.isNotEmpty) return item.help;
    }
    return '';
  }

  /// 按字段类型动态渲染
  List<Widget> _fieldsFor(Iterable<DriverItemDef> items) =>
      [for (final item in items) _fieldFor(item)];

  /// 字段标签：中文显示名 + 必填星号。
  /// 用 Text.rich 保证浮动 label 在 outline 边框 gap 内不被裁切
  /// （Row 作为 label 高度测量不准，TextField 会出现顶部裁切）。
  Widget _fieldLabel(DriverItemDef item) => Text.rich(
        TextSpan(
          text: fieldDisplayName(item.name),
          style: const TextStyle(fontWeight: FontWeight.w600),
          children: [
            if (item.required)
              const TextSpan(
                  text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      );

  Widget _fieldFor(DriverItemDef item) {
    final help = fieldHelpZh(item.name, item.help);
    switch (item.type) {
      case 'bool':
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: _fieldLabel(item),
          subtitle: help.isEmpty
              ? null
              : Text(help,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
          value: _normalized(item) == true,
          onChanged: (v) => setState(() => _values[item.name] = v),
        );
      case 'select':
        return _selectField(item, help);
      case 'number':
        return _textField(item, help, keyboardType: TextInputType.number);
      case 'text':
        return _textField(item, help, multiline: true);
      default:
        return _textField(item, help);
    }
  }

  Widget _selectField(DriverItemDef item, String help) {
    final opts = item.optionList;
    final current = _normalized(item).toString();
    return DropdownButtonFormField<String>(
      value: opts.contains(current)
          ? current
          : (opts.isNotEmpty ? opts.first : null),
      decoration: InputDecoration(
        label: _fieldLabel(item),
        helperText: help.isEmpty ? null : help,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final o in opts)
          DropdownMenuItem(
              value: o,
              child: Text(optionDisplayName(item.name, o))),
      ],
      onChanged: (v) => setState(() => _values[item.name] = v),
    );
  }

  Widget _textField(DriverItemDef item, String help,
      {bool multiline = false, TextInputType? keyboardType}) {
    final ctrl = _ctrls[item.name];
    if (ctrl == null) return const SizedBox.shrink();
    return _SecretTextField(
      controller: ctrl,
      label: _fieldLabel(item),
      helperText: help.isEmpty ? null : help,
      obscure: isSecretField(item.name),
      multiline: multiline,
      keyboardType: keyboardType,
    );
  }

  /// 当前配置二维码
  void _showExportQr() {
    Get.dialog(AlertDialog(
      title: Text(S.current.qrExport),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(data: _configJson(), size: 260),
            const SizedBox(height: 8),
            Text(S.current.qrExportHint,
                style: Theme.of(Get.context!).textTheme.bodySmall),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(), child: Text(S.current.confirm)),
      ],
    ));
  }
}

/// 文本输入框；[obscure] 为 true 时内容打码并可切换可见
class _SecretTextField extends StatefulWidget {
  final TextEditingController controller;
  final Widget label;
  final String? helperText;
  final bool obscure;
  final bool multiline;
  final TextInputType? keyboardType;

  const _SecretTextField({
    required this.controller,
    required this.label,
    this.helperText,
    this.obscure = false,
    this.multiline = false,
    this.keyboardType,
  });

  @override
  State<_SecretTextField> createState() => _SecretTextFieldState();
}

class _SecretTextFieldState extends State<_SecretTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    // 打码与多行互斥：敏感字段固定单行
    final masked = widget.obscure && _hidden;
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType ??
          (widget.multiline ? TextInputType.multiline : null),
      maxLines: masked ? 1 : (widget.multiline ? 4 : 1),
      minLines: 1,
      obscureText: masked,
      decoration: InputDecoration(
        label: widget.label,
        helperText: widget.helperText,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(_hidden ? Icons.visibility_off : Icons.visibility,
                    size: 20),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}

/// 驱动选择底部弹层：滑动动画 + 搜索过滤 + 中文名
class _DriverPickerSheet extends StatefulWidget {
  final List<String> drivers;
  final String current;

  const _DriverPickerSheet({required this.drivers, required this.current});

  @override
  State<_DriverPickerSheet> createState() => _DriverPickerSheetState();
}

class _DriverPickerSheetState extends State<_DriverPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.drivers
        : widget.drivers
            .where((d) =>
                d.toLowerCase().contains(_query.toLowerCase()) ||
                driverDisplayName(d).contains(_query))
            .toList();
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: S.current.searchDriver,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, i) {
                  final d = filtered[i];
                  return ListTile(
                    dense: true,
                    title: Text(driverDisplayName(d)),
                    subtitle: d != driverDisplayName(d)
                        ? Text(d, style: const TextStyle(fontSize: 12))
                        : null,
                    trailing: d == widget.current
                        ? Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary)
                        : null,
                    onTap: () => Navigator.of(context).pop(d),
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
