import 'dart:convert';

/// 站点配置（内嵌服务器或远程 OpenList/AList 服务器）。
///
/// [authHash] 存的是 StaticHash 而非明文密码：
/// `sha256(password + "-" + "https://github.com/alist-org/alist")`，
/// 与 OpenList /api/auth/login/hash 的要求一致，也避免本地存明文。
class Site {
  final String id;
  final String name;
  final String url;
  final String username;
  final String authHash;
  final bool isEmbedded;
  final bool otpEnabled;

  const Site({
    required this.id,
    required this.name,
    required this.url,
    required this.username,
    required this.authHash,
    required this.isEmbedded,
    this.otpEnabled = false,
  });

  Site copyWith({
    String? name,
    String? url,
    String? username,
    String? authHash,
    bool? otpEnabled,
  }) {
    return Site(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      authHash: authHash ?? this.authHash,
      isEmbedded: isEmbedded,
      otpEnabled: otpEnabled ?? this.otpEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'username': username,
        'authHash': authHash,
        'isEmbedded': isEmbedded,
        'otpEnabled': otpEnabled,
      };

  factory Site.fromJson(Map<String, dynamic> json) => Site(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        username: json['username'] as String,
        authHash: (json['authHash'] as String?) ?? '',
        isEmbedded: (json['isEmbedded'] as bool?) ?? false,
        otpEnabled: (json['otpEnabled'] as bool?) ?? false,
      );

  String encode() => jsonEncode(toJson());

  factory Site.decode(String raw) =>
      Site.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
