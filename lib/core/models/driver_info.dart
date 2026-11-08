/// 驱动定义（/api/admin/driver/info）：动态生成存储表单用。
class DriverItemDef {
  final String name;
  final String type; // string / bool / select / number / text
  final String default_;
  final String options; // select 类型的可选值，逗号分隔
  final bool required;
  final String help;

  const DriverItemDef({
    required this.name,
    required this.type,
    required this.default_,
    required this.options,
    required this.required,
    required this.help,
  });

  factory DriverItemDef.fromJson(Map<String, dynamic> json) => DriverItemDef(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? 'string',
        default_: json['default'] as String? ?? '',
        options: json['options'] as String? ?? '',
        required: json['required'] as bool? ?? false,
        help: json['help'] as String? ?? '',
      );

  /// select 的可选项列表
  List<String> get optionList => options
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

class DriverInfo {
  final List<DriverItemDef> common; // 挂载路径、备注、缓存等通用项
  final List<DriverItemDef> additional; // 驱动专属项

  const DriverInfo({required this.common, required this.additional});

  factory DriverInfo.fromJson(Map<String, dynamic> json) => DriverInfo(
        common: ((json['common'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DriverItemDef.fromJson)
            .toList(),
        additional: ((json['additional'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DriverItemDef.fromJson)
            .toList(),
      );
}
