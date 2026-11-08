/// 文件类型判定与展示辅助。
///
/// 服务端 /api/fs/list 的 type 字段在部分版本恒为 0（unknown），
/// 因此按扩展名判断，与服务端行为解耦。
class FileTypes {
  static const _imageExts = {
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'heic', 'heif',
    'svg', 'ico', 'tiff', 'tif', 'avif',
  };
  static const _videoExts = {
    'mp4', 'mkv', 'avi', 'mov', 'wmv', 'flv', 'webm', 'm4v', '3gp',
    'ts', 'mpg', 'mpeg', 'rmvb', 'rm', 'vob', 'm2ts', 'ogv', 'hevc',
  };
  static const _audioExts = {
    'mp3', 'flac', 'aac', 'ogg', 'wav', 'm4a', 'wma', 'ape', 'opus',
    'amr', 'mid', 'aiff', 'alac',
  };
  static const _textExts = {
    'txt', 'md', 'markdown', 'json', 'xml', 'yaml', 'yml', 'ini', 'cfg',
    'conf', 'log', 'csv', 'tsv', 'html', 'htm', 'css', 'js', 'ts', 'jsx',
    'tsx', 'dart', 'java', 'kt', 'kts', 'go', 'py', 'rb', 'php', 'c', 'h',
    'cpp', 'hpp', 'cc', 'sh', 'bat', 'ps1', 'sql', 'toml', 'gradle',
    'properties', 'gitignore', 'dockerfile', 'makefile', 'cmake', 'srt',
    'ass', 'vtt', 'lrc',
  };
  static const _archiveExts = {
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz', 'zst', 'tgz', 'tbz2',
  };

  static String ext(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static bool isImage(String name) => _imageExts.contains(ext(name));
  static bool isVideo(String name) => _videoExts.contains(ext(name));
  static bool isAudio(String name) => _audioExts.contains(ext(name));
  static bool isText(String name) => _textExts.contains(ext(name));
  static bool isArchive(String name) => _archiveExts.contains(ext(name));
  static bool isPdf(String name) => ext(name) == 'pdf';
  static bool isApk(String name) => ext(name) == 'apk';

  /// 预览方式分类（决定点击文件后的行为）。
  static bool previewableAsImage(String name) => isImage(name);
  static bool previewableAsText(String name) => isText(name);
  static bool playable(String name) => isVideo(name) || isAudio(name);

  static String category(String name) {
    if (isImage(name)) return 'image';
    if (isVideo(name)) return 'video';
    if (isAudio(name)) return 'audio';
    if (isText(name)) return 'text';
    if (isArchive(name)) return 'archive';
    if (isPdf(name)) return 'pdf';
    if (isApk(name)) return 'apk';
    return 'other';
  }
}

/// 大小/时间格式化。
class Formatters {
  static String fileSize(int bytes) {
    if (bytes < 0) return '';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double v = bytes.toDouble();
    int i = 0;
    while (v >= 1024 && i < units.length - 1) {
      v /= 1024;
      i++;
    }
    final s = i == 0 ? v.toStringAsFixed(0) : v.toStringAsFixed(v >= 100 ? 0 : 1);
    return '$s ${units[i]}';
  }

  static String dateTime(DateTime? t) {
    if (t == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}';
  }

  /// 时长格式化（播放器用）：h:mm:ss 或 mm:ss。
  static String duration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
}
