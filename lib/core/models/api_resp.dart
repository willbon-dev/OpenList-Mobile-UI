/// OpenList 统一响应包装：所有 /api/* 接口（含错误）都返回 HTTP 200，
/// 业务结果靠 code 区分（200 成功）。
class ApiResp<T> {
  final int code;
  final String message;
  final T? data;

  const ApiResp({required this.code, required this.message, this.data});

  bool get isOk => code == 200;

  factory ApiResp.fromJson(
    Map<String, dynamic> json,
    T? Function(dynamic raw)? parseData,
  ) {
    final code = (json['code'] as num?)?.toInt() ?? 0;
    return ApiResp<T>(
      code: code,
      message: (json['message'] as String?) ?? '',
      // 错误响应的 data 为 null，直接 parse 会把真实错误掩盖成类型转换异常
      data: parseData != null && code == 200
          ? parseData(json['data'])
          : json['data'] as T?,
    );
  }
}

/// 服务器未初始化时（内嵌首启）需要引导走 /api/public/init/setup
class ServerNotInitializedException implements Exception {
  final String message;
  ServerNotInitializedException(this.message);

  @override
  String toString() => message;
}

/// token 失效（服务器重启 / logout / 改密），需要重新登录
class SessionExpiredException implements Exception {
  final String message;
  SessionExpiredException(this.message);

  @override
  String toString() => message;
}

/// 需要两步验证码（code 402）
class OtpRequiredException implements Exception {
  final String message;
  OtpRequiredException(this.message);

  @override
  String toString() => message;
}

/// 受密码保护的目录（code 403 且 message 指向密码）
class PasswordRequiredException implements Exception {
  final String message;
  PasswordRequiredException(this.message);

  @override
  String toString() => message;
}

/// 其他业务错误（HTTP 200 但 code != 200，或真实网络错误）
class OpenListApiException implements Exception {
  final int code;
  final String message;

  OpenListApiException(this.code, this.message);

  @override
  String toString() => message.isEmpty ? 'code $code' : message;
}

/// 判断 403 是否为"目录密码"错误（OpenList 对象密码校验失败的 message）
bool isPasswordError(int code, String message) {
  if (code != 403) return false;
  final m = message.toLowerCase();
  return m.contains('password') || m.contains('密码');
}
