import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../contant/native_bridge.dart';
import '../core/api/openlist_client.dart';
import '../core/models/site.dart';
import '../core/storage/site_store.dart';
import 'auth_service.dart';

/// 站点管理：站点列表 / 当前站点 / 内嵌站点自动化。
///
/// 内嵌站点（isEmbedded=true，id 固定 [embeddedSiteId]）在首次运行时自动
/// 创建，地址随内嵌服务器端口动态刷新。
class SiteManager extends GetxService {
  static const String embeddedSiteId = 'embedded';
  static const int _defaultPort = 5244;

  final RxList<Site> sites = <Site>[].obs;
  final Rxn<Site> current = Rxn<Site>();

  final SiteStore _store = SiteStore();

  static SiteManager get to => Get.find<SiteManager>();

  Future<void> init() async {
    var loaded = await _store.loadSites();
    final port = await _embeddedPort();
    final embeddedUrl = 'http://localhost:$port';

    final embeddedIdx = loaded.indexWhere((s) => s.id == embeddedSiteId);
    if (embeddedIdx >= 0) {
      loaded[embeddedIdx] =
          loaded[embeddedIdx].copyWith(url: embeddedUrl);
    } else {
      loaded = [
        Site(
          id: embeddedSiteId,
          name: 'OpenList',
          url: embeddedUrl,
          username: 'admin',
          authHash: '',
          isEmbedded: true,
        ),
        ...loaded,
      ];
    }

    sites.assignAll(loaded);

    final savedId = await _store.loadCurrentSiteId();
    current.value = sites.firstWhere(
      (s) => s.id == savedId,
      orElse: () => sites.first,
    );
    await _persist();
  }

  Future<int> _embeddedPort() async {
    try {
      return await NativeBridge.android.getOpenListHttpPort();
    } catch (e) {
      debugPrint('getOpenListHttpPort failed: $e');
      return _defaultPort;
    }
  }

  /// 内嵌服务器重启后（端口可能变化）刷新内嵌站点地址。
  Future<void> refreshEmbedded() async {
    final idx = sites.indexWhere((s) => s.id == embeddedSiteId);
    if (idx < 0) return;
    final port = await _embeddedPort();
    final url = 'http://localhost:$port';
    if (sites[idx].url == url) return;
    sites[idx] = sites[idx].copyWith(url: url);
    if (current.value?.id == embeddedSiteId) {
      current.refresh();
    }
    await _persist();
  }

  void setCurrent(Site site) {
    if (!sites.any((s) => s.id == site.id)) return;
    current.value = sites.firstWhere((s) => s.id == site.id);
    _store.saveCurrentSiteId(current.value!.id);
  }

  Future<Site> addSite({
    required String name,
    required String url,
    required String username,
    required String password,
    bool otpEnabled = false,
  }) async {
    final site = Site(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.isEmpty ? _hostOf(url) : name,
      url: OpenListClient.normalizeBaseUrl(url),
      username: username,
      authHash:
          password.isEmpty ? '' : OpenListClient.staticHash(password),
      isEmbedded: false,
      otpEnabled: otpEnabled,
    );
    sites.add(site);
    await _persist();
    return site;
  }

  Future<void> updateSite(Site site) async {
    final idx = sites.indexWhere((s) => s.id == site.id);
    if (idx < 0) return;
    sites[idx] = site;
    if (current.value?.id == site.id) current.refresh();
    Get.find<AuthService>().invalidate(site.id);
    await _persist();
  }

  Future<void> removeSite(String id) async {
    if (id == embeddedSiteId) return; // 内嵌站点不可删除
    sites.removeWhere((s) => s.id == id);
    Get.find<AuthService>().invalidate(id);
    if (current.value?.id == id) {
      current.value = sites.isEmpty ? null : sites.first;
    }
    await _persist();
  }

  Site? byId(String id) {
    for (final s in sites) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> _persist() => _store.saveSites(sites.toList());

  String _hostOf(String url) {
    try {
      return Uri.parse(url).host;
    } catch (_) {
      return url;
    }
  }
}
