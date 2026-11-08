import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/models/site.dart';
import '../../generated/l10n.dart';
import '../../services/site_manager.dart';
import 'site_edit_page.dart';

/// 站点管理：列表 + 添加/编辑/设默认/删除。
class SiteManagePage extends StatelessWidget {
  const SiteManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = SiteManager.to;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.siteManage),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEdit(context, null),
        child: const Icon(Icons.add),
      ),
      body: Obx(() => ListView(
            children: [
              for (final site in manager.sites)
                _SiteTile(
                  site: site,
                  isCurrent: manager.current.value?.id == site.id,
                  onTap: () => _openEdit(context, site),
                  onSetDefault: () => manager.setCurrent(site),
                  onDelete: site.isEmbedded
                      ? null
                      : () => _confirmDelete(context, site),
                ),
            ],
          )),
    );
  }

  void _openEdit(BuildContext context, Site? site) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SiteEditPage(site: site)),
    );
  }

  void _confirmDelete(BuildContext context, Site site) {
    Get.dialog(AlertDialog(
      title: Text(S.current.siteManage),
      content: Text(S.current.deleteSiteConfirm(site.name)),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(S.current.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onError,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            Get.back();
            SiteManager.to.removeSite(site.id);
          },
          child: Text(S.current.delete),
        ),
      ],
    ));
  }
}

class _SiteTile extends StatelessWidget {
  final Site site;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback? onDelete;

  const _SiteTile({
    required this.site,
    required this.isCurrent,
    required this.onTap,
    required this.onSetDefault,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: site.isEmbedded
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.secondaryContainer,
        child: Icon(
          site.isEmbedded ? Icons.smartphone : Icons.dns,
          color: site.isEmbedded
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSecondaryContainer,
        ),
      ),
      title: Row(
        children: [
          Flexible(child: Text(site.name, overflow: TextOverflow.ellipsis)),
          if (isCurrent) ...[
            const SizedBox(width: 8),
            _Badge(
              label: S.current.defaultSite,
              color: theme.colorScheme.primaryContainer,
              textColor: theme.colorScheme.onPrimaryContainer,
            ),
          ],
          if (site.isEmbedded) ...[
            const SizedBox(width: 8),
            _Badge(
              label: S.current.embeddedSite,
              color: theme.colorScheme.secondaryContainer,
              textColor: theme.colorScheme.onSecondaryContainer,
            ),
          ],
        ],
      ),
      subtitle: Text(site.url, overflow: TextOverflow.ellipsis),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'default') {
            onSetDefault();
          } else if (value == 'delete') {
            onDelete?.call();
          }
        },
        itemBuilder: (_) => [
          if (!isCurrent)
            PopupMenuItem(
              value: 'default',
              child: Text(S.current.setAsDefault),
            ),
          if (onDelete != null)
            PopupMenuItem(
              value: 'delete',
              child: Text(S.current.delete),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: textColor),
      ),
    );
  }
}
