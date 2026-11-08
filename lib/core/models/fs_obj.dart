/// /api/fs/list 返回的单个文件/目录条目。
class FsObj {
  final String name;
  final int size;
  final bool isDir;
  final DateTime? modified;
  final DateTime? created;
  final String sign;
  final String thumb;
  final int type;

  const FsObj({
    required this.name,
    required this.size,
    required this.isDir,
    this.modified,
    this.created,
    this.sign = '',
    this.thumb = '',
    this.type = 0,
  });

  factory FsObj.fromJson(Map<String, dynamic> json) => FsObj(
        name: json['name'] as String? ?? '',
        size: (json['size'] as num?)?.toInt() ?? 0,
        isDir: json['is_dir'] as bool? ?? false,
        modified: _ts(json['modified']),
        created: _ts(json['created']),
        sign: json['sign'] as String? ?? '',
        thumb: json['thumb'] as String? ?? '',
        type: (json['type'] as num?)?.toInt() ?? 0,
      );

  static DateTime? _ts(dynamic v) {
    if (v == null) return null;
    if (v is num) {
      final ms = v.toInt();
      if (ms <= 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    final s = v.toString();
    if (s.isEmpty) return null;
    // 毫秒时间戳
    final ms = int.tryParse(s);
    if (ms != null && ms > 0) {
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    // OpenList API 返回 ISO-8601 字符串（如 2026-05-06T04:02:30.000Z）
    return DateTime.tryParse(s);
  }
}

/// /api/fs/list 的 data 部分。
class FsListResult {
  final List<FsObj> content;
  final int total;
  final bool write;

  const FsListResult({
    required this.content,
    required this.total,
    this.write = false,
  });

  factory FsListResult.fromJson(Map<String, dynamic> json) {
    final rawList = json['content'];
    return FsListResult(
      content: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(FsObj.fromJson)
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
      write: json['write'] as bool? ?? false,
    );
  }
}

/// /api/fs/get 的 data 部分（文件详情 + 播放/下载用的 raw_url）。
class FsGetResult {
  final String name;
  final int size;
  final bool isDir;
  final DateTime? modified;
  final DateTime? created;
  final String sign;
  final String thumb;
  final String rawUrl;
  final int type;

  const FsGetResult({
    required this.name,
    required this.size,
    required this.isDir,
    this.modified,
    this.created,
    this.sign = '',
    this.thumb = '',
    this.rawUrl = '',
    this.type = 0,
  });

  factory FsGetResult.fromJson(Map<String, dynamic> json) => FsGetResult(
        name: json['name'] as String? ?? '',
        size: (json['size'] as num?)?.toInt() ?? 0,
        isDir: json['is_dir'] as bool? ?? false,
        modified: FsObj._ts(json['modified']),
        created: FsObj._ts(json['created']),
        sign: json['sign'] as String? ?? '',
        thumb: json['thumb'] as String? ?? '',
        rawUrl: json['raw_url'] as String? ?? '',
        type: (json['type'] as num?)?.toInt() ?? 0,
      );
}

/// /api/fs/dirs 返回的目录项。
class DirEntry {
  final String name;
  final DateTime? modified;

  const DirEntry({required this.name, this.modified});

  factory DirEntry.fromJson(Map<String, dynamic> json) => DirEntry(
        name: json['name'] as String? ?? '',
        modified: FsObj._ts(json['modified']),
      );
}

/// /api/fs/search 返回的条目。
class SearchItem {
  final String parent;
  final String name;
  final bool isDir;
  final int size;
  final int type;

  const SearchItem({
    required this.parent,
    required this.name,
    required this.isDir,
    required this.size,
    required this.type,
  });

  factory SearchItem.fromJson(Map<String, dynamic> json) => SearchItem(
        parent: json['parent'] as String? ?? '/',
        name: json['name'] as String? ?? '',
        isDir: json['is_dir'] as bool? ?? false,
        size: (json['size'] as num?)?.toInt() ?? 0,
        type: (json['type'] as num?)?.toInt() ?? 0,
      );
}

/// /api/fs/search 的分页结果。
class SearchResult {
  final List<SearchItem> content;
  final int total;

  const SearchResult({required this.content, required this.total});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final rawList = json['content'];
    return SearchResult(
      content: rawList is List
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(SearchItem.fromJson)
              .toList()
          : const [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}

/// /api/public/settings 的站点公开信息。
class SiteSettings {
  final String siteTitle;
  final String version;
  final String logo;
  final String favicon;

  const SiteSettings({
    required this.siteTitle,
    required this.version,
    this.logo = '',
    this.favicon = '',
  });

  factory SiteSettings.fromMap(Map<String, dynamic> map) => SiteSettings(
        siteTitle: map['site_title'] as String? ?? 'OpenList',
        version: map['version'] as String? ?? '',
        logo: map['logo'] as String? ?? '',
        favicon: map['favicon'] as String? ?? '',
      );
}

/// /api/me 返回的当前用户（permission 为位掩码）。
class OpenListUser {
  static const permSeeHidden = 1 << 0;
  static const permNoPassword = 1 << 1;
  static const permOfflineDownload = 1 << 2;
  static const permWrite = 1 << 3; // mkdir / upload
  static const permRename = 1 << 4;
  static const permMove = 1 << 5;
  static const permCopy = 1 << 6;
  static const permDelete = 1 << 7;

  final int id;
  final String username;
  final String basePath;
  final int role;
  final int permission;
  final bool otp;

  const OpenListUser({
    required this.id,
    required this.username,
    required this.basePath,
    required this.role,
    required this.permission,
    required this.otp,
  });

  bool get isAdmin => role == 1;
  bool get canWrite => permission & permWrite != 0;
  bool get canRename => permission & permRename != 0;
  bool get canMove => permission & permMove != 0;
  bool get canCopy => permission & permCopy != 0;
  bool get canDelete => permission & permDelete != 0;

  factory OpenListUser.fromJson(Map<String, dynamic> json) => OpenListUser(
        id: (json['id'] as num?)?.toInt() ?? 0,
        username: json['username'] as String? ?? '',
        basePath: json['base_path'] as String? ?? '/',
        role: (json['role'] as num?)?.toInt() ?? 0,
        permission: (json['permission'] as num?)?.toInt() ?? 0,
        otp: json['otp'] as bool? ?? false,
      );
}
