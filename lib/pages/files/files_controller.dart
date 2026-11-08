import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/openlist_client.dart';
import '../../core/models/api_resp.dart';
import '../../core/models/fs_obj.dart';
import '../../core/models/site.dart';
import '../../core/utils/file_types.dart';
import '../../contant/native_bridge.dart';
import '../../generated/l10n.dart';
import '../../services/auth_service.dart';
import '../../services/site_manager.dart';
import '../../utils/download_manager.dart';
import '../../utils/service_manager.dart';
import '../sites/init_server_dialog.dart';
import 'preview/image_preview_page.dart';
import 'preview/text_preview_page.dart';
import 'preview/video_player_page.dart';

const int kFilesPerPage = 50;

/// 文件排序方式
enum FileSortMode { name, modified, type }

/// 文件浏览控制器：目录加载/分页、搜索、多选、目录操作。
///
/// 认证流程：authHash 为空 → 弹登录框；402 → 弹 OTP 框；403 密码目录 →
/// 弹密码框；401 由 AuthService 自动重登（无凭据时同样落到登录框）。
class FilesController extends GetxController {
  final Rxn<Site> site = Rxn<Site>();

  final path = '/'.obs;
  final items = <FsObj>[].obs;
  final total = 0.obs;
  final loading = false.obs;
  final loadingMore = false.obs;
  final error = Rxn<String>();
  final canWrite = false.obs;

  final _passwords = <String, String>{}; // 目录密码缓存（仅内存）
  int _page = 1;
  bool _noMore = false;

  // 多选
  final selectionMode = false.obs;
  final selected = <FsObj>[].obs;

  // 搜索
  final searchMode = false.obs;
  final searching = false.obs;
  final searchResults = <SearchItem>[].obs;
  final searchTotal = 0.obs;
  int _searchPage = 1;
  String _keywords = '';
  bool _searchNoMore = false;

  // 排序：文件名 / 修改时间 / 类型，+方向；本地持久化
  final sortMode = FileSortMode.name.obs;
  final sortAscending = true.obs;

  FilesController({Site? initialSite}) {
    site.value = initialSite ?? SiteManager.to.current.value;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSortPrefs();
  }

  @override
  void onReady() async {
    super.onReady();
    final ready = await ensureSiteReady();
    if (ready) await loadDirectory('/');
  }

  Future<void> _loadSortPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final m = sp.getInt('file_sort_mode') ?? 0;
      if (m >= 0 && m < FileSortMode.values.length) {
        sortMode.value = FileSortMode.values[m];
      }
      sortAscending.value = sp.getBool('file_sort_asc') ?? true;
    } catch (_) {}
  }

  Future<void> _saveSortPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setInt('file_sort_mode', sortMode.value.index);
      await sp.setBool('file_sort_asc', sortAscending.value);
    } catch (_) {}
  }

  /// 切换排序：选择当前模式则反转方向；
  /// 切到"时间"默认最新在前，其余默认升序
  void setSortMode(FileSortMode mode) {
    if (sortMode.value == mode) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortMode.value = mode;
      sortAscending.value = mode != FileSortMode.modified;
    }
    _saveSortPrefs();
    // 已加载的列表立即重排（搜索结果无修改时间，时间模式回退按名称）
    if (searchMode.value) {
      final list = searchResults.toList();
      list.sort((a, b) {
        if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
        int r;
        if (sortMode.value == FileSortMode.type) {
          final aE = FileTypes.ext(a.name);
          final bE = FileTypes.ext(b.name);
          r = aE != bE
              ? aE.compareTo(bE)
              : a.name.toLowerCase().compareTo(b.name.toLowerCase());
        } else {
          r = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        return sortAscending.value ? r : -r;
      });
      searchResults.assignAll(list);
    } else if (items.isNotEmpty) {
      items.assignAll(_sorted(items.toList()));
    }
  }

  String get siteId => site.value?.id ?? '';
  bool get hasMore => !_noMore && items.length < total.value;
  bool get searchHasMore => !_searchNoMore && searchResults.length < searchTotal.value;

  // ----------------------------------------------------------- load flow

  /// 进入文件页前的准备：
  /// - 内嵌站点：等服务就绪 → 未初始化走向导 / 无凭据则自动接管密码（免密）
  /// - 仍无凭据时弹登录框
  /// 返回 false 表示用户放弃，页面保持空态。
  Future<bool> ensureSiteReady() async {
    final s = site.value;
    if (s == null) return false;

    if (s.isEmbedded) {
      await _waitForEmbeddedServer();
      final probe = OpenListClient(s);
      try {
        final initialized = await probe.initStatus();
        if (initialized == false) {
          final password = await showInitServerDialog(Get.context!, s.url,
              defaultUsername: s.username);
          if (password == null) return false;
          // 初始化成功：保存凭据并用新密码登录
          final hash = OpenListClient.staticHash(password);
          final updated = s.copyWith(authHash: hash);
          await SiteManager.to.updateSite(updated);
          await Get.find<AuthService>().relogin(updated, hash);
          site.value = SiteManager.to.byId(s.id) ?? updated;
        } else if (site.value!.authHash.isEmpty) {
          // 服务器已初始化但 App 未绑定密码：
          // 直接生成随机密码接管（免密登录），用户之后可在站点编辑中重置
          await _claimEmbeddedPassword();
        }
      } on OpenListApiException {
        // 远程 AList 无 init_status 接口（404）或暂时连不上：继续
      } catch (_) {}
    }

    if (site.value!.authHash.isEmpty) {
      return await promptLogin();
    }
    return true;
  }

  /// 等内嵌服务器就绪：未运行则拉起，轮询 /ping 最多 ~20s。
  Future<void> _waitForEmbeddedServer() async {
    final s = site.value;
    if (s == null) return;
    final sm = ServiceManager.instance;
    try {
      if (!await sm.checkServiceStatus()) {
        await sm.startService();
      }
    } catch (_) {}
    final ping = Dio(BaseOptions(
      baseUrl: OpenListClient.normalizeBaseUrl(s.url),
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
    ));
    for (var i = 0; i < 20; i++) {
      try {
        final r = await ping.get('/ping');
        if (r.statusCode == 200) return;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// 内嵌站点免密：生成随机密码，为原生 UI 创建/重置专用内置账号
  /// （不动 admin 账号，WebView 管理后台登录态不受影响）。
  static const String embeddedAppUsername = 'listpocket_app';

  Future<void> _claimEmbeddedPassword() async {
    final s = site.value!;
    final pwd = _randomPassword();
    try {
      await NativeBridge.android.ensureAppUser(embeddedAppUsername, pwd);
      final hash = OpenListClient.staticHash(pwd);
      final updated = s.copyWith(username: embeddedAppUsername, authHash: hash);
      await SiteManager.to.updateSite(updated);
      await Get.find<AuthService>().relogin(updated, hash);
      site.value = SiteManager.to.byId(s.id) ?? updated;
    } catch (e) {
      debugPrint('claim embedded app user failed: $e');
    }
  }

  static String _randomPassword() {
    const chars =
        'abcdefghijkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(
        16, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// 登录框（无凭据时），支持修改用户名。成功返回 true。
  Future<bool> promptLogin() async {
    final s = site.value!;
    final usernameCtrl = TextEditingController(text: s.username);
    final passwordCtrl = TextEditingController();
    final otpCtrl = TextEditingController();
    final needsOtp = s.otpEnabled;

    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text(S.current.login),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(s.name),
          const SizedBox(height: 12),
          TextField(
            controller: usernameCtrl,
            decoration: InputDecoration(
              labelText: S.current.siteUsername,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: passwordCtrl,
            obscureText: true,
            decoration: InputDecoration(
              labelText: S.current.sitePassword,
              border: const OutlineInputBorder(),
            ),
          ),
          if (needsOtp) ...[
            const SizedBox(height: 12),
            TextField(
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: S.current.enterOtp,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () => Get.back(result: true),
          child: Text(S.current.login),
        ),
      ],
    ));

    if (ok != true || passwordCtrl.text.isEmpty) return false;
    final newUsername = usernameCtrl.text.trim();
    final target = newUsername.isEmpty || newUsername == s.username
        ? s
        : s.copyWith(username: newUsername);
    final hash = OpenListClient.staticHash(passwordCtrl.text);
    try {
      await Get.find<AuthService>().relogin(
        target,
        hash,
        otpCode: needsOtp ? otpCtrl.text.trim() : null,
      );
    } on OtpRequiredException {
      final otp = await _promptOtp();
      if (otp == null) return false;
      await Get.find<AuthService>().relogin(target, hash, otpCode: otp);
    } catch (e) {
      NativeBridge.common.longToast(S.current.loginFailed(e.toString()));
      return false;
    }
    await SiteManager.to.updateSite(target.copyWith(authHash: hash));
    site.value = SiteManager.to.byId(s.id) ?? target;
    return true;
  }

  Future<String?> _promptOtp() async {
    final ctrl = TextEditingController();
    final code = await Get.dialog<String>(AlertDialog(
      title: Text(S.current.otpRequired),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: S.current.enterOtp,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () => Get.back(result: ctrl.text.trim()),
          child: Text(S.current.confirm),
        ),
      ],
    ));
    return (code == null || code.isEmpty) ? null : code;
  }

  Future<void> loadDirectory(String p, {bool refresh = false}) async {
    final s = site.value;
    if (s == null) return;
    error.value = null;
    loading.value = true;
    try {
      final result = await Get.find<AuthService>().execute<FsListResult>(
        s,
        (client) => client.fsList(
          p,
          password: _passwords[p],
          refresh: refresh,
          page: 1,
          perPage: kFilesPerPage,
        ),
      );
      path.value = p;
      _page = 1;
      _noMore = false;
      items.assignAll(_sorted(result.content));
      total.value = result.total;
      canWrite.value = result.write;
      selectionMode.value = false;
      selected.clear();
    } on PasswordRequiredException {
      loading.value = false;
      final pwd = await _promptFolderPassword(p);
      if (pwd != null && pwd.isNotEmpty) {
        _passwords[p] = pwd;
        return loadDirectory(p, refresh: refresh);
      }
      error.value = S.current.protectedFolder;
    } on OtpRequiredException {
      loading.value = false;
      final otp = await _promptOtp();
      if (otp != null) {
        final result = await Get.find<AuthService>().execute<FsListResult>(
          s,
          (client) => client.fsList(p,
              password: _passwords[p],
              refresh: refresh,
              page: 1,
              perPage: kFilesPerPage),
          otpCode: otp,
        );
        path.value = p;
        _page = 1;
        _noMore = false;
        items.assignAll(_sorted(result.content));
        total.value = result.total;
      }
    } catch (e) {
      error.value = e.toString();
      items.clear();
      total.value = 0;
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    final s = site.value;
    if (s == null || loadingMore.value || _noMore || searchMode.value) return;
    loadingMore.value = true;
    try {
      final result = await Get.find<AuthService>().execute<FsListResult>(
        s,
        (client) => client.fsList(
          path.value,
          password: _passwords[path.value],
          page: _page + 1,
          perPage: kFilesPerPage,
        ),
      );
      _page++;
      items.addAll(_sorted(result.content, excludeLoaded: true));
      if (result.content.isEmpty ||
          (result.total > 0 && items.length >= result.total)) {
        _noMore = true;
      }
      total.value = result.total;
    } on SessionExpiredException {
      // execute 内部已重试过一次；再失败说明凭据有问题
      error.value = S.current.sessionExpired;
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
      _noMore = true;
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> refreshCurrent() => loadDirectory(path.value, refresh: true);

  List<FsObj> _sorted(List<FsObj> list, {bool excludeLoaded = false}) {
    final existing = excludeLoaded ? items.map((e) => e.name).toSet() : <String>{};
    final fresh =
        list.where((e) => !existing.contains(e.name)).toList();
    final mode = sortMode.value;
    final asc = sortAscending.value;
    int nameCmp(FsObj a, FsObj b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());
    int cmp(FsObj a, FsObj b) {
      switch (mode) {
        case FileSortMode.modified:
          final aT = a.modified?.millisecondsSinceEpoch ?? 0;
          final bT = b.modified?.millisecondsSinceEpoch ?? 0;
          if (aT != bT) return aT.compareTo(bT);
          return nameCmp(a, b);
        case FileSortMode.type:
          final aE = FileTypes.ext(a.name);
          final bE = FileTypes.ext(b.name);
          if (aE != bE) return aE.compareTo(bE);
          return nameCmp(a, b);
        case FileSortMode.name:
          return nameCmp(a, b);
      }
    }

    fresh.sort((a, b) {
      // 目录始终排在文件前面，排序方式只作用于同组之内
      if (a.isDir != b.isDir) return a.isDir ? -1 : 1;
      final r = cmp(a, b);
      return asc ? r : -r;
    });
    return fresh;
  }

  // -------------------------------------------------------------- search

  Future<void> startSearch(String keywords) async {
    final s = site.value;
    if (s == null || keywords.isEmpty) return;
    _keywords = keywords;
    _searchPage = 1;
    _searchNoMore = false;
    searchMode.value = true;
    searching.value = true;
    searchResults.clear();
    searchTotal.value = 0;
    try {
      final r = await Get.find<AuthService>()
          .execute<SearchResult>(s, (c) => c.fsSearch('/', keywords, page: 1));
      searchResults.assignAll(r.content);
      searchTotal.value = r.total;
      if (r.content.isEmpty || r.content.length >= r.total) {
        _searchNoMore = true;
      }
    } on OpenListApiException catch (e) {
      if (e.code == 404) {
        NativeBridge.common.longToast(S.current.searchNotEnabled);
      } else {
        NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
      }
      searchMode.value = false;
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
      searchMode.value = false;
    } finally {
      searching.value = false;
    }
  }

  Future<void> loadMoreSearch() async {
    final s = site.value;
    if (s == null || searching.value || _searchNoMore) return;
    searching.value = true;
    try {
      final r = await Get.find<AuthService>().execute<SearchResult>(
          s, (c) => c.fsSearch('/', _keywords, page: _searchPage + 1));
      _searchPage++;
      searchResults.addAll(r.content);
      if (r.content.isEmpty || searchResults.length >= r.total) {
        _searchNoMore = true;
      }
      searchTotal.value = r.total;
    } catch (e) {
      _searchNoMore = true;
    } finally {
      searching.value = false;
    }
  }

  void exitSearch() {
    searchMode.value = false;
    searchResults.clear();
  }

  // ----------------------------------------------------------- selection

  void toggleSelect(FsObj obj) {
    if (selected.any((e) => e.name == obj.name)) {
      selected.removeWhere((e) => e.name == obj.name);
    } else {
      selected.add(obj);
    }
    if (selected.isEmpty) selectionMode.value = false;
  }

  void exitSelectionMode() {
    selectionMode.value = false;
    selected.clear();
  }

  void enterSelectionMode(FsObj first) {
    selectionMode.value = true;
    selected.assignAll([first]);
  }

  void selectAll() {
    selected.assignAll(items);
  }

  // --------------------------------------------------------- fs mutations

  Future<bool> createFolder(String name) async {
    final s = site.value;
    if (s == null || name.isEmpty) return false;
    final target = joinPath(path.value, name);
    try {
      await Get.find<AuthService>()
          .execute(s, (c) => c.mkdir(target));
      NativeBridge.common.toast(S.current.createSuccess);
      await refreshCurrent();
      return true;
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
      return false;
    }
  }

  Future<bool> rename(FsObj obj, String newName) async {
    final s = site.value;
    if (s == null || newName.isEmpty) return false;
    try {
      await Get.find<AuthService>().execute(
        s,
        (c) => c.rename(joinPath(path.value, obj.name), newName),
      );
      NativeBridge.common.toast(S.current.renameSuccess);
      await refreshCurrent();
      return true;
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
      return false;
    }
  }

  Future<bool> delete(List<FsObj> objs) async {
    final s = site.value;
    if (s == null || objs.isEmpty) return false;
    try {
      await Get.find<AuthService>().execute(
        s,
        (c) => c.remove(path.value, objs.map((e) => e.name).toList()),
      );
      NativeBridge.common.toast(S.current.deleteSuccess);
      exitSelectionMode();
      await refreshCurrent();
      return true;
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
      return false;
    }
  }

  Future<void> move(List<FsObj> objs, String dstDir) async {
    final s = site.value;
    if (s == null || objs.isEmpty) return;
    try {
      await Get.find<AuthService>().execute(
        s,
        (c) => c.move(
            path.value, dstDir, objs.map((e) => e.name).toList()),
      );
      NativeBridge.common.toast(S.current.moveSuccess);
      exitSelectionMode();
      await refreshCurrent();
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
    }
  }

  Future<void> copy(List<FsObj> objs, String dstDir) async {
    final s = site.value;
    if (s == null || objs.isEmpty) return;
    try {
      await Get.find<AuthService>().execute(
        s,
        (c) => c.copy(
            path.value, dstDir, objs.map((e) => e.name).toList()),
      );
      NativeBridge.common.toast(S.current.copySuccess);
      exitSelectionMode();
      await refreshCurrent();
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
    }
  }

  Future<void> switchSite(Site newSite) async {
    if (site.value?.id == newSite.id) return;
    site.value = newSite;
    SiteManager.to.setCurrent(newSite);
    _passwords.clear();
    exitSearch();
    exitSelectionMode();
    final ready = await ensureSiteReady();
    if (ready) {
      await loadDirectory('/');
    }
  }

  // -------------------------------------------------------------- helpers

  /// 点击文件条目：按类型分流到预览/播放/下载打开。
  void openFile(FsObj obj, {String? dirOverride}) {
    final dir = dirOverride ?? path.value;
    if (obj.isDir) {
      loadDirectory(joinPath(dir, obj.name));
      return;
    }
    final filePath = joinPath(dir, obj.name);
    switch (FileTypes.category(obj.name)) {
      case 'image':
        final images = <FsObj>[];
        var initialIndex = 0;
        for (final item in items) {
          if (FileTypes.isImage(item.name)) {
            if (item.name == obj.name) initialIndex = images.length;
            images.add(item);
          }
        }
        final list = images.isEmpty ? [obj] : images;
        Get.to(() => ImagePreviewPage(
              site: site.value!,
              dirPath: dir,
              images: list,
              initialIndex:
                  images.isEmpty ? 0 : initialIndex,
            ));
        break;
      case 'video':
      case 'audio':
        Get.to(() => VideoPlayerPage(
              site: site.value!,
              filePath: filePath,
              title: obj.name,
              isAudio: FileTypes.isAudio(obj.name),
            ));
        break;
      case 'text':
        Get.to(() => TextPreviewPage(
              site: site.value!,
              filePath: filePath,
              title: obj.name,
            ));
        break;
      default:
        download(obj, dirOverride: dir);
        break;
    }
  }

  /// 搜索结果点击：跳转到所在目录并打开文件。
  Future<void> openByPath(String fullPath) async {
    final dir = parentOf(fullPath);
    final name = fullPath.split('/').last;
    exitSearch();
    await loadDirectory(dir);
    final obj = items.firstWhere(
      (e) => e.name == name,
      orElse: () => FsObj(name: name, size: 0, isDir: false),
    );
    openFile(obj, dirOverride: dir);
  }

  /// 直链下载（sign 缺失时回退 fsGet 取 raw_url）。
  Future<void> download(FsObj obj, {String? dirOverride}) async {
    final s = site.value;
    if (s == null) return;
    final dir = dirOverride ?? path.value;
    final filePath = joinPath(dir, obj.name);
    try {
      String url;
      if (obj.sign.isNotEmpty) {
        url = OpenListClient(s).downloadUrl(filePath, sign: obj.sign);
      } else {
        final info = await Get.find<AuthService>()
            .execute<FsGetResult>(s, (c) => c.fsGet(filePath));
        url = info.rawUrl;
      }
      if (url.isEmpty) {
        NativeBridge.common.longToast(S.current.operationFailed('no url'));
        return;
      }
      NativeBridge.common.toast(S.current.downloadStarted);
      DownloadManager.downloadFileWithProgress(url: url, filename: obj.name);
    } catch (e) {
      NativeBridge.common.longToast(S.current.operationFailed(e.toString()));
    }
  }

  Future<void> downloadSelected() async {
    final list = selected.toList();
    exitSelectionMode();
    for (final obj in list) {
      await download(obj);
    }
  }

  // ---------------------------------------------------------------- upload

  final uploading = false.obs;
  final uploadName = ''.obs;
  final uploadSent = 0.obs;
  final uploadTotal = 0.obs;

  /// 选文件并流式上传到当前目录（带进度对话框）。
  Future<void> uploadFiles() async {
    final s = site.value;
    if (s == null) return;
    if (!canWrite.value) {
      NativeBridge.common
          .longToast(S.current.operationFailed('no write permission'));
      return;
    }
    final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (picked == null || picked.paths.isEmpty) return;
    final paths = picked.paths.whereType<String>().toList();

    uploading.value = true;
    Get.dialog(
      const _UploadProgressDialog(),
      barrierDismissible: false,
    );

    var ok = 0;
    String? lastError;
    for (final p in paths) {
      final file = File(p);
      try {
        uploadName.value = p.split(Platform.pathSeparator).last;
        uploadSent.value = 0;
        uploadTotal.value = await file.length();
        await Get.find<AuthService>().execute(
          s,
          (c) => c.putFile(
            file,
            joinPath(path.value, uploadName.value),
            contentType: _contentTypeFor(uploadName.value),
            lastModified: file.lastModifiedSync(),
            onProgress: (sent, total) {
              uploadSent.value = sent;
              uploadTotal.value = total;
            },
          ),
        );
        ok++;
      } catch (e) {
        lastError = e.toString();
      }
    }

    uploading.value = false;
    if (Get.isDialogOpen == true) Get.back();
    if (ok > 0) {
      NativeBridge.common.toast(S.current.uploadSuccess);
      await refreshCurrent();
    } else {
      NativeBridge.common
          .longToast(S.current.uploadFailed(lastError ?? 'unknown'));
    }
  }

  static String _contentTypeFor(String name) {
    switch (FileTypes.category(name)) {
      case 'image':
        return 'image/${FileTypes.ext(name)}';
      case 'video':
        return 'video/${FileTypes.ext(name)}';
      case 'audio':
        return 'audio/${FileTypes.ext(name)}';
      case 'text':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  static String joinPath(String dir, String name) {
    if (dir.endsWith('/')) return '$dir$name';
    return '$dir/$name';
  }

  static String parentOf(String dir) {
    if (dir == '/' || dir.isEmpty) return '/';
    final p = dir.substring(0, dir.length - 1);
    final idx = p.lastIndexOf('/');
    return idx <= 0 ? '/' : p.substring(0, idx + 1);
  }

  List<String> get breadcrumbs {
    final parts =
        path.value.split('/').where((e) => e.isNotEmpty).toList();
    final crumbs = <String>['/'];
    var acc = '';
    for (final part in parts) {
      acc = '$acc/$part';
      crumbs.add(acc);
    }
    return crumbs;
  }

  Future<String?> _promptFolderPassword(String dir) async {
    final ctrl = TextEditingController();
    final pwd = await Get.dialog<String>(AlertDialog(
      title: Text(S.current.protectedFolder),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(dir),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            autofocus: true,
            obscureText: true,
            decoration: InputDecoration(
              labelText: S.current.folderPassword,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () => Get.back(result: ctrl.text),
          child: Text(S.current.confirm),
        ),
      ],
    ));
    return pwd;
  }
}

/// 上传进度对话框（Obx 读取 controller 的上传状态）。
class _UploadProgressDialog extends StatelessWidget {
  const _UploadProgressDialog();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FilesController>();
    return AlertDialog(
      title: Text(S.current.uploading),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                c.uploadName.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )),
          const SizedBox(height: 12),
          Obx(() => LinearProgressIndicator(
                value: c.uploadTotal.value > 0
                    ? (c.uploadSent.value / c.uploadTotal.value)
                        .clamp(0.0, 1.0)
                    : null,
              )),
          const SizedBox(height: 8),
          Obx(() => Text(
                '${Formatters.fileSize(c.uploadSent.value)}'
                ' / ${Formatters.fileSize(c.uploadTotal.value)}',
                style: Theme.of(context).textTheme.labelSmall,
              )),
        ],
      ),
    );
  }
}
