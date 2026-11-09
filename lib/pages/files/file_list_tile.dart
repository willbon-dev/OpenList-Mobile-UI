import 'package:flutter/material.dart';

import '../../core/models/fs_obj.dart';
import '../../core/utils/file_types.dart';
import '../../generated/l10n.dart';

/// 文件/目录列表条目。
class FileListTile extends StatelessWidget {
  final FsObj obj;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// 多选模式：trailing 显示勾选圆圈，行可点选
  final bool selectionMode;

  /// 当前条目是否已被勾选（配合 [selectionMode] 高亮）
  final bool selected;

  const FileListTile({
    super.key,
    required this.obj,
    required this.onTap,
    required this.onLongPress,
    this.selectionMode = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = <String>[
      if (!obj.isDir) Formatters.fileSize(obj.size),
      if (obj.modified != null) Formatters.dateTime(obj.modified),
    ];

    return ListTile(
      leading: _leadingIcon(theme),
      title: Text(
        obj.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitleParts.isEmpty
          ? null
          : Text(
              subtitleParts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
      trailing: selectionMode
          ? Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 24,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            )
          : (obj.isDir ? const Icon(Icons.chevron_right) : null),
      tileColor: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
          : null,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Widget _leadingIcon(ThemeData theme) {
    if (obj.isDir) {
      return Icon(
        Icons.folder,
        color: theme.colorScheme.primary,
        size: 36,
      );
    }
    if (obj.thumb.isNotEmpty && FileTypes.isImage(obj.name)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Image.network(
            obj.thumb,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackIcon(theme),
          ),
        ),
      );
    }
    return _fallbackIcon(theme);
  }

  Widget _fallbackIcon(ThemeData theme) {
    IconData icon;
    Color? color;
    switch (FileTypes.category(obj.name)) {
      case 'image':
        icon = Icons.image;
        color = theme.colorScheme.tertiary;
        break;
      case 'video':
        icon = Icons.movie;
        color = theme.colorScheme.secondary;
        break;
      case 'audio':
        icon = Icons.music_note;
        color = theme.colorScheme.secondary;
        break;
      case 'text':
        icon = Icons.description;
        break;
      case 'archive':
        icon = Icons.folder_zip;
        break;
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = theme.colorScheme.error;
        break;
      case 'apk':
        icon = Icons.android;
        color = const Color(0xFF3DDC84);
        break;
      default:
        icon = Icons.insert_drive_file;
    }
    return Icon(icon, size: 32, color: color);
  }
}
