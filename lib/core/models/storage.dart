import 'dart:convert';

/// 服务端存储（/api/admin/storage/*）。
///
/// 保留原始 JSON 以支持编辑时的完整回传（update 需要全量字段）。
class StorageInfo {
  final Map<String, dynamic> raw;

  StorageInfo(this.raw);

  int get id => (raw['id'] as num?)?.toInt() ?? 0;
  String get mountPath => raw['mount_path'] as String? ?? '';
  String get driver => raw['driver'] as String? ?? '';

  /// addition 兼容两种形态：服务端记录为 JSON 字符串，
  /// 导出的配置（二维码/JSON）为内嵌对象
  String get addition {
    final v = raw['addition'];
    if (v is String) return v;
    if (v != null) return jsonEncode(v);
    return '{}';
  }
  String get remark => raw['remark'] as String? ?? '';
  String get status => raw['status'] as String? ?? '';
  bool get disabled => raw['disabled'] as bool? ?? false;

  /// 解析 addition JSON（失败返回空 Map）
  Map<String, dynamic> get additionMap {
    try {
      final v = jsonDecode(addition);
      return v is Map<String, dynamic> ? v : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
