import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../models/api_resp.dart';
import '../models/driver_info.dart';
import '../models/fs_obj.dart';
import '../models/site.dart';
import '../models/storage.dart';
import '../models/task.dart';

/// OpenList/AList 服务器 HTTP API 客户端。
///
/// 所有 /api/* 响应都是 HTTP 200 + {code,message,data} 包装，
/// 由 [_unwrap] 统一解包并映射为 [OpenListApiException] 系列异常。
class OpenListClient {
  final Site site;
  final Dio _dio;

  String? _token;

  /// 登录密码哈希（StaticHash），由 AuthService 在登录成功后注入。
  set token(String? value) => _token = value;
  String? get token => _token;

  OpenListClient(this.site, {Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = normalizeBaseUrl(site.url)
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(minutes: 10)
      ..sendTimeout = const Duration(minutes: 10);
  }

  /// 去首尾空白与结尾斜杠，供 baseUrl 与站点存储共用。
  static String normalizeBaseUrl(String url) {
    var u = url.trim();
    if (u.isEmpty) return u;
    u = u.endsWith('/') ? u.substring(0, u.length - 1) : u;
    return u;
  }

  /// OpenList 登录密码 StaticHash：sha256(password + "-" + salt)
  static const String hashSalt = 'https://github.com/alist-org/alist';

  static String staticHash(String password) =>
      sha256.convert(utf8.encode('$password-$hashSalt')).toString();

  /// 路径按段编码（保留 / 结构），用于 /d、/p 等直链拼接。
  static String encodePath(String path) => path
      .split('/')
      .map((seg) => seg.isEmpty ? '' : Uri.encodeComponent(seg))
      .join('/');

  Map<String, String> get _authHeaders =>
      _token == null ? {} : {'Authorization': _token!};

  // ---------------------------------------------------------------- auth

  /// POST /api/auth/login/hash —— 返回 token。
  /// 抛 [OtpRequiredException] 表示需要两步验证码。
  Future<String> login({
    required String authHash,
    String? otpCode,
  }) async {
    final resp = await _unwrap<Map<String, dynamic>>(
      _dio.post('/api/auth/login/hash', data: {
        'username': site.username,
        'password': authHash,
        if (otpCode != null && otpCode.isNotEmpty) 'otp_code': otpCode,
      }),
      parse: (raw) => raw as Map<String, dynamic>,
    );
    _token = resp['token'] as String?;
    if (_token == null || _token!.isEmpty) {
      throw OpenListApiException(0, 'empty token');
    }
    return _token!;
  }

  Future<void> logout() async {
    try {
      await _dio.get('/api/auth/logout', options: Options(headers: _authHeaders));
    } finally {
      _token = null;
    }
  }

  /// GET /api/me —— 当前用户与权限位。
  Future<OpenListUser> me() => _unwrap(
        _dio.get('/api/me', options: Options(headers: _authHeaders)),
        parse: (raw) => OpenListUser.fromJson(raw as Map<String, dynamic>),
      );

  // -------------------------------------------------------------- public

  /// GET /api/public/settings —— 免认证站点公开设置。
  Future<SiteSettings> publicSettings() => _unwrap(
        _dio.get('/api/public/settings'),
        parse: (raw) => SiteSettings.fromMap(raw as Map<String, dynamic>),
      );

  /// GET /api/public/init_status —— 服务器是否已初始化（v4 专属，老 AList 404）。
  Future<bool?> initStatus() async {
    try {
      return await _unwrap(
        _dio.get('/api/public/init_status'),
        parse: (raw) => (raw as Map<String, dynamic>)['initialized'] as bool?,
      );
    } on OpenListApiException catch (e) {
      if (e.code == 404) return null; // 老版本 AList 无此接口
      rethrow;
    }
  }

  /// POST /api/public/init/setup —— 首次初始化（仅未初始化服务器可用）。
  Future<void> initSetup({
    required String username,
    required String password,
    String? siteTitle,
  }) async {
    await _unwrap(
      _dio.post('/api/public/init/setup', data: {
        'username': username,
        'password': password,
        'site_title': siteTitle ?? 'OpenList',
      }),
      parse: (raw) => null,
    );
  }

  // ------------------------------------------------------------------ fs

  Future<FsListResult> fsList(
    String path, {
    String? password,
    bool refresh = false,
    int page = 1,
    int perPage = 0,
  }) =>
      _unwrap(
        _dio.post('/api/fs/list', options: Options(headers: _authHeaders),
            data: {
              'path': path,
              'page': page,
              'per_page': perPage,
              'password': password ?? '',
              'refresh': refresh,
            }),
        parse: (raw) => FsListResult.fromJson(raw as Map<String, dynamic>),
      );

  Future<FsGetResult> fsGet(String path, {String? password}) => _unwrap(
        _dio.post('/api/fs/get', options: Options(headers: _authHeaders),
            data: {
              'path': path,
              'password': password ?? '',
            }),
        parse: (raw) => FsGetResult.fromJson(raw as Map<String, dynamic>),
      );

  Future<List<DirEntry>> fsDirs(String path, {String? password}) => _unwrap(
        _dio.post('/api/fs/dirs', options: Options(headers: _authHeaders),
            data: {
              'path': path,
              'password': password ?? '',
            }),
        parse: (raw) => (raw['content'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DirEntry.fromJson)
            .toList(),
      );

  Future<SearchResult> fsSearch(
    String parent,
    String keywords, {
    int scope = 0,
    int page = 1,
    int perPage = 50,
  }) =>
      _unwrap(
        _dio.post('/api/fs/search', options: Options(headers: _authHeaders),
            data: {
              'parent': parent,
              'keywords': keywords,
              'scope': scope,
              'page': page,
              'per_page': perPage,
            }),
        parse: (raw) => SearchResult.fromJson(raw as Map<String, dynamic>),
      );

  Future<void> mkdir(String path) => _unwrap(
        _dio.post('/api/fs/mkdir', options: Options(headers: _authHeaders),
            data: {'path': path}),
        parse: (raw) => null,
      );

  Future<void> rename(String path, String newName) => _unwrap(
        _dio.post('/api/fs/rename', options: Options(headers: _authHeaders),
            data: {'path': path, 'name': newName}),
        parse: (raw) => null,
      );

  Future<void> remove(String dir, List<String> names) => _unwrap(
        _dio.post('/api/fs/remove', options: Options(headers: _authHeaders),
            data: {'dir': dir, 'names': names}),
        parse: (raw) => null,
      );

  Future<void> move(String srcDir, String dstDir, List<String> names) =>
      _unwrap(
        _dio.post('/api/fs/move', options: Options(headers: _authHeaders),
            data: {
              'src_dir': srcDir,
              'dst_dir': dstDir,
              'names': names,
            }),
        parse: (raw) => null,
      );

  Future<void> copy(String srcDir, String dstDir, List<String> names) =>
      _unwrap(
        _dio.post('/api/fs/copy', options: Options(headers: _authHeaders),
            data: {
              'src_dir': srcDir,
              'dst_dir': dstDir,
              'names': names,
            }),
        parse: (raw) => null,
      );

  /// PUT /api/fs/put —— 流式上传。
  ///
  /// 服务端用 url.PathUnescape 解码 File-Path（不转换 + 号），
  /// 因此用 Uri.encodeComponent 完整编码是安全的。
  Future<void> putFile(
    File file,
    String remotePath, {
    String? contentType,
    DateTime? lastModified,
    bool overwrite = true,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final length = await file.length();
    await _unwrap(
      _dio.put(
        '/api/fs/put',
        data: file.openRead(),
        options: Options(headers: {
          ..._authHeaders,
          'File-Path': Uri.encodeComponent(remotePath),
          'Content-Type': contentType ?? 'application/octet-stream',
          'Content-Length': length.toString(),
          'Overwrite': overwrite.toString(),
          if (lastModified != null)
            'Last-Modified':
                lastModified.millisecondsSinceEpoch.toString(),
        }),
        cancelToken: cancelToken,
        onSendProgress: onProgress,
      ),
      parse: (raw) => null,
    );
  }

  // --------------------------------------------------------------- admin

  /// 管理端：存储列表（需要管理员 token）
  Future<List<StorageInfo>> adminListStorages() => _unwrap(
        _dio.get('/api/admin/storage/list',
            queryParameters: {'page': 1, 'per_page': 0},
            options: Options(headers: _authHeaders)),
        parse: (raw) => ((raw['content'] as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(StorageInfo.new)
            .toList(),
      );

  /// 管理端：可用驱动名称列表
  Future<List<String>> adminDriverNames() => _unwrap(
        _dio.get('/api/admin/driver/names',
            options: Options(headers: _authHeaders)),
        parse: (raw) =>
            ((raw as List?) ?? const []).map((e) => e.toString()).toList(),
      );

  /// 管理端：挂载新存储
  Future<void> adminCreateStorage(Map<String, dynamic> body) => _unwrap(
        _dio.post('/api/admin/storage/create',
            options: Options(headers: _authHeaders), data: body),
        parse: (raw) => null,
      );

  /// 管理端：更新存储（需全量字段）
  Future<void> adminUpdateStorage(Map<String, dynamic> body) => _unwrap(
        _dio.post('/api/admin/storage/update',
            options: Options(headers: _authHeaders), data: body),
        parse: (raw) => null,
      );

  /// 管理端：删除存储
  Future<void> adminDeleteStorage(int id) => _unwrap(
        _dio.post('/api/admin/storage/delete',
            options: Options(headers: _authHeaders), data: {'id': id}),
        parse: (raw) => null,
      );

  /// 管理端：启用/停用存储
  Future<void> adminSetStorageEnabled(int id, bool enable) => _unwrap(
        _dio.post(
            enable
                ? '/api/admin/storage/enable'
                : '/api/admin/storage/disable',
            options: Options(headers: _authHeaders), data: {'id': id}),
        parse: (raw) => null,
      );

  /// 管理端：驱动定义（含全部配置项定义，动态表单用）
  Future<DriverInfo> adminDriverInfo(String driver) => _unwrap(
        _dio.get('/api/admin/driver/info',
            queryParameters: {'driver': driver},
            options: Options(headers: _authHeaders)),
        parse: (raw) => DriverInfo.fromJson(raw as Map<String, dynamic>),
      );

  /// 任务列表：cat = offline_download/upload/copy/move/decompress
  Future<List<TaskInfo>> taskList(String cat, {required bool done}) =>
      _unwrap(
        _dio.get('/api/task/$cat/${done ? 'done' : 'undone'}',
            options: Options(headers: _authHeaders)),
        parse: (raw) => ((raw as List?) ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(TaskInfo.new)
            .toList(),
      );

  /// 任务操作：action = cancel / delete / retry（单个 tid）
  Future<void> taskAction(String cat, String action, String tid) => _unwrap(
        _dio.post('/api/task/$cat/$action',
            options: Options(headers: _authHeaders), data: {'tid': tid}),
        parse: (raw) => null,
      );

  /// 清理已完成/已失败任务：action = clear_done / clear_succeeded / clear_errored
  Future<void> taskClear(String cat, String action) => _unwrap(
        _dio.post('/api/task/$cat/$action',
            options: Options(headers: _authHeaders)),
        parse: (raw) => null,
      );

  // ------------------------------------------------------------- download

  /// 下载直链：/d/<path>?sign=xxx（免 token，服务端校验 sign）。
  String downloadUrl(String path, {String sign = ''}) {
    final base = _dio.options.baseUrl;
    final s = sign.isEmpty ? '' : (sign.startsWith('?') ? sign : '?sign=$sign');
    return '$base/d${encodePath(path)}$s';
  }

  // ------------------------------------------------------------- internal

  Future<T> _unwrap<T>(
    Future<Response> future, {
    required T Function(dynamic raw) parse,
  }) async {
    Response resp;
    try {
      resp = await future;
    } on DioException catch (e) {
      throw OpenListApiException(
        e.response?.statusCode ?? 0,
        e.message ?? 'network error',
      );
    }
    final body = resp.data;
    if (body is! Map<String, dynamic>) {
      // /d 等非 JSON 响应或网关错误页
      throw OpenListApiException(resp.statusCode ?? 0, 'unexpected response');
    }
    final apiResp = ApiResp<T>.fromJson(body, parse);
    if (apiResp.isOk) return apiResp.data as T;
    throw _mapError(apiResp.code, apiResp.message);
  }

  Exception _mapError(int code, String message) {
    switch (code) {
      case 401:
        return SessionExpiredException(message);
      case 402:
        return OtpRequiredException(message);
      default:
        if (isPasswordError(code, message)) {
          return PasswordRequiredException(message);
        }
        return OpenListApiException(code, message);
    }
  }
}
