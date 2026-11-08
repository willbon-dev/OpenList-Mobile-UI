import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api/openlist_client.dart';
import '../../core/models/api_resp.dart';
import '../../core/models/site.dart';
import '../../contant/native_bridge.dart';
import '../../generated/l10n.dart';
import '../../services/auth_service.dart';
import '../../services/site_manager.dart';
import 'init_server_dialog.dart';

/// 站点编辑/新建表单。
///
/// 内嵌站点：URL 与用户名锁定，额外提供「重置内嵌管理员密码」
/// （复用原生 setAdminPwd）；若服务器未初始化，走 /api/public/init/setup 引导。
class SiteEditPage extends StatefulWidget {
  final Site? site; // null = 新建

  const SiteEditPage({super.key, this.site});

  @override
  State<SiteEditPage> createState() => _SiteEditPageState();
}

class _SiteEditPageState extends State<SiteEditPage> {
  late final TextEditingController _name;
  late final TextEditingController _url;
  late final TextEditingController _username;
  late final TextEditingController _password;
  late final TextEditingController _otp;

  bool get _isEmbedded => widget.site?.isEmbedded ?? false;
  bool get _isNew => widget.site == null;

  bool _testing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.site?.name ?? '');
    _url = TextEditingController(text: widget.site?.url ?? '');
    _username = TextEditingController(text: widget.site?.username ?? 'admin');
    _password = TextEditingController();
    _otp = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _username.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? S.current.addSite : S.current.editSite),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_isEmbedded) ...[
            _infoBanner(
              context,
              icon: Icons.smartphone,
              text: S.current.embeddedSiteDesc,
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: S.current.siteName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _url,
            enabled: !_isEmbedded,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              labelText: 'URL',
              hintText: _isEmbedded ? null : S.current.siteUrlHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _username,
            enabled: !_isEmbedded,
            decoration: InputDecoration(
              labelText: S.current.siteUsername,
              helperText: _isEmbedded ? S.current.embeddedUserManaged : null,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: InputDecoration(
              labelText: S.current.sitePassword,
              border: const OutlineInputBorder(),
              helperText: _isEmbedded ? S.current.resetEmbeddedPwdDesc : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otp,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S.current.siteOtpCode,
              hintText: S.current.otpCodeHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testing ? null : _onTest,
                  icon: _testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_tethering),
                  label: Text(_testing
                      ? S.current.testing
                      : S.current.testConnection),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _saving ? null : _onSave,
                  icon: const Icon(Icons.check),
                  label: Text(S.current.save),
                ),
              ),
            ],
          ),
          if (_isEmbedded) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _onResetEmbeddedPassword,
              icon: const Icon(Icons.lock_reset),
              label: Text(S.current.resetEmbeddedPwd),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoBanner(BuildContext context,
      {required IconData icon, required String text}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// 用表单当前值构造测试站点（不落库）。
  Site? _siteForTest() {
    final url =
        OpenListClient.normalizeBaseUrl(_url.text.trim());
    if (url.isEmpty) return null;
    return Site(
      id: widget.site?.id ?? 'test',
      name: _name.text.trim(),
      url: url,
      username: _username.text.trim(),
      authHash: '',
      isEmbedded: _isEmbedded,
    );
  }

  /// 建一个临时 client 做连通性测试；未初始化服务器会引导初始化。
  Future<void> _onTest() async {
    final site = _siteForTest();
    if (site == null) return;
    setState(() => _testing = true);
    try {
      final client = OpenListClient(site);
      final settings = await client.publicSettings();
      final initialized = await client.initStatus();
      if (!mounted) return;
      if (initialized == false) {
        await _promptInit(site);
      } else {
        Get.snackbar(
          S.current.connectionOk,
          '${settings.siteTitle} · ${settings.version}',
          backgroundColor: Get.theme.colorScheme.primaryContainer,
        );
      }
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        S.current.connectionFailed(e.toString()),
        '',
        backgroundColor: Get.theme.colorScheme.errorContainer,
      );
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _promptInit(Site site) async {
    final password = await showInitServerDialog(context, site.url);
    if (password != null && mounted) {
      // 初始化成功：用初始化时设置的凭据补登
      try {
        await Get.find<AuthService>().relogin(
          site,
          OpenListClient.staticHash(password),
          otpCode: _otp.text.trim(),
        );
      } catch (_) {}
    }
  }

  Future<void> _onResetEmbeddedPassword() async {
    final password = _password.text.trim();
    if (password.isEmpty) {
      NativeBridge.common.toast(S.current.sitePassword);
      return;
    }
    await NativeBridge.android.setAdminPwd(password);
    NativeBridge.common.toast(S.current.resetPwdDone);
  }

  Future<void> _onSave() async {
    final manager = SiteManager.to;
    final name = _name.text.trim();
    final url = OpenListClient.normalizeBaseUrl(_url.text.trim());
    final username = _username.text.trim();
    final password = _password.text.trim();
    final otpCode = _otp.text.trim();

    if (url.isEmpty && !_isEmbedded) {
      NativeBridge.common.toast('URL ${S.current.emptyList}');
      return;
    }
    if (username.isEmpty) {
      NativeBridge.common.toast(S.current.siteUsername);
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isNew) {
        final site = await manager.addSite(
          name: name,
          url: url,
          username: username,
          password: password,
        );
        if (password.isNotEmpty) {
          await Get.find<AuthService>()
              .relogin(site, OpenListClient.staticHash(password), otpCode: otpCode);
        }
      } else {
        var updated = widget.site!.copyWith(
          name: name,
          url: widget.site!.isEmbedded ? widget.site!.url : url,
          username: username,
        );
        if (password.isNotEmpty) {
          final hash = OpenListClient.staticHash(password);
          updated = updated.copyWith(authHash: hash);
          if (widget.site!.isEmbedded) {
            // 内嵌站点改密码 = 直接改服务器密码并登录
            await NativeBridge.android.setAdminPwd(password);
          }
          await Get.find<AuthService>()
              .relogin(updated, hash, otpCode: otpCode);
        } else {
          await manager.updateSite(updated);
        }
      }
      NativeBridge.common.toast(S.current.operationSuccess);
      if (mounted) Navigator.of(context).pop();
    } on OtpRequiredException {
      NativeBridge.common.longToast(S.current.otpRequired);
    } catch (e) {
      NativeBridge.common.longToast(S.current.loginFailed(e.toString()));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
