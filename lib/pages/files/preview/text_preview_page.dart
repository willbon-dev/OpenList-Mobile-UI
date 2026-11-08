import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../../../core/models/site.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/file_types.dart';
import '../../../services/auth_service.dart';

const int kMaxTextPreviewBytes = 1 * 1024 * 1024; // 1MB

/// 文本/代码预览（≤1MB），带简单语法高亮。
class TextPreviewPage extends StatefulWidget {
  final Site site;
  final String filePath;
  final String title;

  const TextPreviewPage({
    super.key,
    required this.site,
    required this.filePath,
    required this.title,
  });

  @override
  State<TextPreviewPage> createState() => _TextPreviewPageState();
}

class _TextPreviewPageState extends State<TextPreviewPage> {
  String? _content;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // 必须经 AuthService 调 fsGet: 无 token 时 401，
      // 登录后返回的 raw_url 自带 sign，后续 /p 请求无需再带 token
      final info = await AuthService.to
          .execute(widget.site, (client) => client.fsGet(widget.filePath));
      if (info.size > kMaxTextPreviewBytes) {
        setState(() {
          _error = S.current.textTooLarge;
          _loading = false;
        });
        return;
      }
      // 文本走 /p 代理路径，避免 /d 302 到不可跨域的网盘直链
      final url = info.rawUrl;
      final uri = Uri.parse(url);
      final bytes = await _fetchBytes(uri);
      final text = utf8.decode(bytes, allowMalformed: true);
      setState(() {
        _content = text;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<List<int>> _fetchBytes(Uri uri) async {
    final ioClient = HttpClient();
    try {
      final req = await ioClient.getUrl(uri);
      final resp = await req.close();
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in resp) {
        builder.add(chunk);
        if (builder.length > kMaxTextPreviewBytes * 2) {
          throw Exception(S.current.textTooLarge);
        }
      }
      return builder.takeBytes();
    } finally {
      ioClient.close(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!,
                        textAlign: TextAlign.center),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: HighlightView(
                    _content!,
                    language: _languageFor(widget.title),
                    theme: theme.brightness == Brightness.dark
                        ? atomOneDarkTheme
                        : githubTheme,
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
    );
  }

  String _languageFor(String name) {
    switch (FileTypes.ext(name)) {
      case 'dart':
        return 'dart';
      case 'json':
        return 'json';
      case 'js':
        return 'javascript';
      case 'ts':
        return 'typescript';
      case 'py':
        return 'python';
      case 'go':
        return 'go';
      case 'java':
        return 'java';
      case 'kt':
      case 'kts':
        return 'kotlin';
      case 'sh':
      case 'bat':
      case 'ps1':
        return 'bash';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'xml':
      case 'html':
      case 'htm':
        return 'xml';
      case 'css':
        return 'css';
      case 'md':
      case 'markdown':
        return 'markdown';
      case 'sql':
        return 'sql';
      default:
        // HighlightView 不接受 null 语言，未知扩展名用纯文本
        return 'plaintext';
    }
  }
}
