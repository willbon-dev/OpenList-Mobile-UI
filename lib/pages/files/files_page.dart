import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/fs_obj.dart';
import '../../core/utils/file_types.dart';
import '../../generated/l10n.dart';
import '../../services/site_manager.dart';
import '../sites/site_manage_page.dart';
import 'file_list_tile.dart';
import 'files_controller.dart';
import 'path_picker_dialog.dart';

/// 原生文件浏览 Tab（主页）。
class FilesScreen extends StatelessWidget {
  const FilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FilesController());

    return Scaffold(
      appBar: const _FilesAppBar(),
      body: const _FilesBody(),
      bottomNavigationBar: const _SelectionBar(),
    );
  }
}

// ------------------------------------------------------------------ appbar

class _FilesAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _FilesAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilesController>();
    return Obx(() {
      if (controller.selectionMode.value) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: controller.exitSelectionMode,
          ),
          title: Text(S.current.selectedCount(controller.selected.length)),
          actions: [
            IconButton(
              icon: const Icon(Icons.select_all),
              tooltip: S.current.selectAll,
              onPressed: controller.selectAll,
            ),
          ],
        );
      }
      if (controller.searchMode.value) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: controller.exitSearch,
          ),
          title: _SearchField(),
        );
      }
      return AppBar(
        title: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showSiteSwitcher(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        SiteManager.to.current.value?.name ??
                            S.current.filesTab,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                )),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: S.current.search,
            onPressed: () => controller.searchMode.value = true,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenu(context, value),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'new_folder',
                child: Row(children: [
                  const Icon(Icons.create_new_folder_outlined, size: 20),
                  const SizedBox(width: 10),
                  Text(S.current.newFolder),
                ]),
              ),
              PopupMenuItem(
                value: 'upload',
                child: Row(children: [
                  const Icon(Icons.upload_file, size: 20),
                  const SizedBox(width: 10),
                  Text(S.current.uploadFile),
                ]),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(children: [
                  const Icon(Icons.refresh, size: 20),
                  const SizedBox(width: 10),
                  Text(S.current.refresh),
                ]),
              ),
              PopupMenuItem(
                value: 'sort',
                child: Row(children: [
                  const Icon(Icons.sort, size: 20),
                  const SizedBox(width: 10),
                  Text(S.current.sort),
                ]),
              ),
              PopupMenuItem(
                value: 'sites',
                child: Row(children: [
                  const Icon(Icons.dns_outlined, size: 20),
                  const SizedBox(width: 10),
                  Text(S.current.siteManage),
                ]),
              ),
            ],
          ),
        ],
      );
    });
  }

  void _onMenu(BuildContext context, String value) {
    final controller = Get.find<FilesController>();
    switch (value) {
      case 'new_folder':
        _promptNewFolder(context, controller);
        break;
      case 'upload':
        controller.uploadFiles();
        break;
      case 'refresh':
        controller.refreshCurrent();
        break;
      case 'sort':
        _showSortSheet(context, controller);
        break;
      case 'sites':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SiteManagePage()),
        );
        break;
    }
  }

  /// 排序面板：三种方式，选当前方式再次点击反转方向（面板保持打开）
  void _showSortSheet(BuildContext context, FilesController controller) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(S.current.sort,
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              for (final mode in FileSortMode.values)
                ListTile(
                  dense: true,
                  leading: Icon(_sortIcon(mode)),
                  title: Text(_sortLabel(mode)),
                  trailing: controller.sortMode.value == mode
                      ? Icon(
                          controller.sortAscending.value
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 18,
                          color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () => controller.setSortMode(mode),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  String _sortLabel(FileSortMode mode) {
    switch (mode) {
      case FileSortMode.name:
        return S.current.sortByName;
      case FileSortMode.modified:
        return S.current.sortByTime;
      case FileSortMode.type:
        return S.current.sortByType;
    }
  }

  IconData _sortIcon(FileSortMode mode) {
    switch (mode) {
      case FileSortMode.name:
        return Icons.sort_by_alpha;
      case FileSortMode.modified:
        return Icons.schedule;
      case FileSortMode.type:
        return Icons.category_outlined;
    }
  }

  void _promptNewFolder(BuildContext context, FilesController controller) {
    final nameCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: Text(S.current.newFolder),
      content: TextField(
        controller: nameCtrl,
        autofocus: true,
        decoration: InputDecoration(
          labelText: S.current.folderName,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = nameCtrl.text.trim();
            Get.back();
            if (name.isNotEmpty) controller.createFolder(name);
          },
          child: Text(S.current.confirm),
        ),
      ],
    ));
  }

  void _showSiteSwitcher(BuildContext context) {
    final controller = Get.find<FilesController>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Obx(() => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final site in SiteManager.to.sites)
                  ListTile(
                    leading: Icon(
                      site.isEmbedded ? Icons.smartphone : Icons.dns,
                    ),
                    title: Text(site.name),
                    subtitle: Text(site.url, overflow: TextOverflow.ellipsis),
                    trailing: site.id == controller.siteId
                        ? Icon(Icons.check,
                            color: Theme.of(ctx).colorScheme.primary)
                        : null,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      controller.switchSite(site);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(S.current.siteManage),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SiteManagePage()),
                    );
                  },
                ),
              ],
            ),
          )),
    );
  }
}

class _SearchField extends StatefulWidget {
  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilesController>();
    return TextField(
      controller: _ctrl,
      focusNode: _focus,
      autofocus: true,
      textInputAction: TextInputAction.search,
      onSubmitted: (v) => controller.startSearch(v.trim()),
      decoration: InputDecoration(
        hintText: S.current.searchKeywordsHint,
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => controller.startSearch(_ctrl.text.trim()),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- body

class _FilesBody extends StatelessWidget {
  const _FilesBody();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilesController>();

    return Column(
      children: [
        // 面包屑
        Obx(() {
          if (controller.searchMode.value) return const SizedBox.shrink();
          return _Breadcrumb(controller: controller);
        }),
        Expanded(
          child: Obx(() {
            if (controller.searchMode.value) {
              return _SearchResults(controller: controller);
            }
            if (controller.loading.value && controller.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            final error = controller.error.value;
            if (error != null && controller.items.isEmpty) {
              return _ErrorView(
                message: error,
                onRetry: controller.refreshCurrent,
              );
            }
            if (controller.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open,
                        size: 56,
                        color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 12),
                    Text(S.current.emptyFolder,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: controller.refreshCurrent,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  if (n.metrics.pixels >=
                      n.metrics.maxScrollExtent - 400) {
                    controller.loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.items.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= controller.items.length) {
                      return Obx(() => controller.loadingMore.value
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                  child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))),
                            )
                          : const SizedBox.shrink());
                    }
                    final obj = controller.items[index];
                    return FileListTile(
                      obj: obj,
                      onTap: () => _onItemTap(context, obj),
                      onLongPress: () => _onItemLongPress(context, obj),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _onItemTap(BuildContext context, FsObj obj) {
    final controller = Get.find<FilesController>();

    if (controller.selectionMode.value) {
      controller.toggleSelect(obj);
      return;
    }
    controller.openFile(obj);
  }

  void _onItemLongPress(BuildContext context, FsObj obj) {
    final controller = Get.find<FilesController>();
    if (controller.searchMode.value) return;
    if (!controller.selectionMode.value) {
      controller.enterSelectionMode(obj);
      return;
    }
    controller.toggleSelect(obj);
  }
}

// -------------------------------------------------------------- breadcrumb

class _Breadcrumb extends StatefulWidget {
  final FilesController controller;

  const _Breadcrumb({required this.controller});

  @override
  State<_Breadcrumb> createState() => _BreadcrumbState();
}

class _BreadcrumbState extends State<_Breadcrumb> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // 靠左显示：路径变化后滚到末尾，保证当前层级可见
    ever(widget.controller.path, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollCtrl,
            child: Row(
              children: [
                for (final crumb in widget.controller.breadcrumbs) ...[
                  // 每级之间以 "/" 分隔（根目录本身即 "/"）
                  if (crumb != '/')
                    Text('/',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.6),
                        )),
                  InkWell(
                    onTap: () => widget.controller.loadDirectory(crumb),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      child: Text(
                        crumb == '/'
                            ? S.current.rootDir
                            : crumb.split('/').last,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: crumb == widget.controller.path.value
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: crumb == widget.controller.path.value
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )),
    );
  }
}

// ----------------------------------------------------------- search result

class _SearchResults extends StatelessWidget {
  final FilesController controller;

  const _SearchResults({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.searching.value && controller.searchResults.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.searchResults.isEmpty) {
        return Center(child: Text(S.current.emptyList));
      }
      return NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 400) {
            controller.loadMoreSearch();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: controller.searchResults.length + 1,
          itemBuilder: (context, index) {
            if (index >= controller.searchResults.length) {
              return Obx(() => controller.searching.value
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          S.current.searchResultCount(
                              controller.searchTotal.value),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ));
            }
            final item = controller.searchResults[index];
            final fullPath =
                FilesController.joinPath(item.parent, item.name);
            return ListTile(
              leading: Icon(
                item.isDir ? Icons.folder : _iconFor(item.name),
                color: item.isDir
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(item.name, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                item.isDir
                    ? item.parent
                    : '${item.parent} · ${Formatters.fileSize(item.size)}',
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                if (item.isDir) {
                  controller.exitSearch();
                  controller.loadDirectory(fullPath);
                } else {
                  controller.openByPath(fullPath);
                }
              },
            );
          },
        ),
      );
    });
  }

  IconData _iconFor(String name) {
    switch (FileTypes.category(name)) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.movie;
      case 'audio':
        return Icons.music_note;
      case 'text':
        return Icons.description;
      case 'archive':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// ----------------------------------------------------------------- states

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off,
                size: 56, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(S.current.retry),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------ selection bar

class _SelectionBar extends StatelessWidget {
  const _SelectionBar();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FilesController>();
    return Obx(() {
      if (!controller.selectionMode.value) return const SizedBox.shrink();
      final theme = Theme.of(context);
      return NavigationBarTheme(
        data: NavigationBarTheme.of(context),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (controller.selected.length == 1)
                  _SelectionAction(
                    icon: Icons.edit,
                    label: S.current.rename,
                    onTap: () => _promptRename(context, controller),
                  ),
                _SelectionAction(
                  icon: Icons.drive_file_move,
                  label: S.current.batchMove,
                  onTap: () => _pickDestination(context, controller, move: true),
                ),
                _SelectionAction(
                  icon: Icons.copy_all,
                  label: S.current.batchCopy,
                  onTap: () => _pickDestination(context, controller, move: false),
                ),
                _SelectionAction(
                  icon: Icons.download,
                  label: S.current.batchDownload,
                  onTap: () => controller.downloadSelected(),
                ),
                _SelectionAction(
                  icon: Icons.delete_outline,
                  label: S.current.batchDelete,
                  onTap: () => _confirmBatchDelete(context, controller),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _pickDestination(BuildContext context, FilesController controller,
      {required bool move}) async {
    final dst = await showPathPickerDialog(
      context,
      title: move ? S.current.moveTo : S.current.copyTo,
      initialDir: controller.path.value,
      site: controller.site.value!,
    );
    if (dst == null) return;
    if (move) {
      controller.move(controller.selected.toList(), dst);
    } else {
      controller.copy(controller.selected.toList(), dst);
    }
  }

  void _promptRename(BuildContext context, FilesController controller) {
    final obj = controller.selected.first;
    final nameCtrl = TextEditingController(text: obj.name);
    Get.dialog(AlertDialog(
      title: Text(S.current.renamePrompt(obj.name)),
      content: TextField(
        controller: nameCtrl,
        autofocus: true,
        decoration: InputDecoration(
          labelText: S.current.fileName,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () {
            final newName = nameCtrl.text.trim();
            Get.back();
            if (newName.isNotEmpty && newName != obj.name) {
              controller.rename(obj, newName);
            }
          },
          child: Text(S.current.confirm),
        ),
      ],
    ));
  }

  void _confirmBatchDelete(BuildContext context, FilesController controller) {
    Get.dialog(AlertDialog(
      title: Text(S.current.batchDelete),
      content: Text(S.current.deleteItemsConfirm(controller.selected.length)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          onPressed: () {
            Get.back();
            controller.delete(controller.selected.toList());
          },
          child: Text(S.current.delete),
        ),
      ],
    ));
  }
}

class _SelectionAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SelectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
