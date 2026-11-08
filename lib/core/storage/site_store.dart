import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/site.dart';

/// 站点列表与当前站点的本地持久化（shared_preferences）。
class SiteStore {
  static const _keySites = 'openlist_sites';
  static const _keyCurrentSiteId = 'openlist_current_site_id';

  Future<List<Site>> loadSites() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_keySites);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Site.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSites(List<Site> sites) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(
      _keySites,
      jsonEncode(sites.map((s) => s.toJson()).toList()),
    );
  }

  Future<String?> loadCurrentSiteId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyCurrentSiteId);
  }

  Future<void> saveCurrentSiteId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyCurrentSiteId, id);
  }
}
