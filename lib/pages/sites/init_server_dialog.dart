import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/api/openlist_client.dart';
import '../../core/models/site.dart';
import '../../contant/native_bridge.dart';
import '../../generated/l10n.dart';

/// 服务器未初始化时的引导对话框（/api/public/init/setup）。
/// 初始化成功时返回管理员密码（供客户端直接登录），取消/失败返回 null。
Future<String?> showInitServerDialog(
  BuildContext context,
  String baseUrl, {
  String defaultUsername = 'admin',
}) async {
  final usernameCtrl = TextEditingController(text: defaultUsername);
  final passwordCtrl = TextEditingController();
  final titleCtrl = TextEditingController(text: 'OpenList');
  final formKey = GlobalKey<FormState>();

  final ok = await Get.dialog<bool>(AlertDialog(
    title: Text(S.current.serverNotInitialized),
    content: Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.current.initServerHint),
          const SizedBox(height: 12),
          TextFormField(
            controller: usernameCtrl,
            decoration: InputDecoration(
              labelText: S.current.siteUsername,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? S.current.emptyList : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: S.current.sitePassword,
              border: const OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? S.current.emptyList : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: titleCtrl,
            decoration: InputDecoration(
              labelText: S.current.initSiteTitle,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Get.back(result: false),
        child: Text(S.current.cancel),
      ),
      FilledButton(
        onPressed: () {
          if (formKey.currentState!.validate()) Get.back(result: true);
        },
        child: Text(S.current.initialize),
      ),
    ],
  ));

  if (ok != true) return null;

  try {
    final password = passwordCtrl.text.trim();
    final client = OpenListClient(Site(
      id: 'init-temp',
      name: 'init',
      url: baseUrl,
      username: usernameCtrl.text.trim(),
      authHash: OpenListClient.staticHash(password),
      isEmbedded: true,
    ));
    await client.initSetup(
      username: usernameCtrl.text.trim(),
      password: password,
      siteTitle: titleCtrl.text.trim(),
    );
    NativeBridge.common.toast(S.current.operationSuccess);
    return password;
  } catch (e) {
    NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
    return null;
  }
}
