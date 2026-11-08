import 'package:get/get.dart';

import '../core/api/openlist_client.dart';
import '../core/models/api_resp.dart';
import '../core/models/fs_obj.dart';
import '../core/models/site.dart';

/// 每站点会话：client + token 缓存 + 登录态。
class _SiteSession {
  final OpenListClient client;
  bool loggedIn = false;

  _SiteSession(this.client);
}

/// 认证服务：管理每站点的登录会话，token 失效时自动重登一次。
///
/// 需要 OTP 的站点无法静默重登 —— [OtpRequiredException] 会抛给 UI，
/// 由界面取到验证码后经 [execute] 的 [otpCode] 参数重试。
class AuthService extends GetxService {
  final Map<String, _SiteSession> _sessions = {};

  static AuthService get to => Get.find<AuthService>();

  OpenListClient? peekClient(String siteId) => _sessions[siteId]?.client;

  /// 断开某站点会话（站点被删除/编辑后调用）。
  void invalidate(String siteId) => _sessions.remove(siteId);

  /// 执行一个需要认证的 API 调用。
  ///
  /// - 会话不存在或未登录：先用 [site.authHash] 登录（无 hash 则抛
  ///   [OpenListApiException] code -1，UI 应引导用户输入密码）。
  /// - 执行中遇到 [SessionExpiredException]：清 token 自动重登一次后重试。
  /// - [otpCode] 非空时用于本次登录。
  Future<T> execute<T>(
    Site site,
    Future<T> Function(OpenListClient client) action, {
    String? otpCode,
  }) async {
    final session = _sessionFor(site);
    if (!session.loggedIn) {
      await _login(session, site, otpCode: otpCode);
    }
    try {
      return await action(session.client);
    } on SessionExpiredException {
      session.loggedIn = false;
      session.client.token = null;
      await _login(session, site, otpCode: otpCode);
      return await action(session.client);
    }
  }

  /// 强制用指定密码重新登录（站点编辑/重置密码后调用）。
  Future<void> relogin(Site site, String authHash, {String? otpCode}) async {
    final updated = site.copyWith(authHash: authHash);
    final session = _sessionFor(updated);
    session.loggedIn = false;
    await _login(session, updated, otpCode: otpCode);
  }

  /// 只测试连通性（不落 token 状态）：public settings 免认证可拿。
  Future<SiteSettings> testConnection(Site site) async {
    final client = OpenListClient(site);
    return client.publicSettings();
  }

  _SiteSession _sessionFor(Site site) {
    return _sessions.putIfAbsent(site.id, () => _SiteSession(OpenListClient(site)));
  }

  Future<void> _login(
    _SiteSession session,
    Site site, {
    String? otpCode,
  }) async {
    if (site.authHash.isEmpty) {
      throw OpenListApiException(-1, 'no credentials');
    }
    await session.client.login(
      authHash: site.authHash,
      otpCode: otpCode,
    );
    session.loggedIn = true;
  }
}
