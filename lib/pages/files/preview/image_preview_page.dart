import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../core/api/openlist_client.dart';
import '../../../core/models/fs_obj.dart';
import '../../../core/models/site.dart';
import '../../../generated/l10n.dart';

/// 图片查看器（PhotoView）：捏合缩放/双击缩放/平移 + 同目录左右翻页。
class ImagePreviewPage extends StatefulWidget {
  final Site site;
  final String dirPath;
  final List<FsObj> images;
  final int initialIndex;

  const ImagePreviewPage({
    super.key,
    required this.site,
    required this.dirPath,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ImagePreviewPage> createState() => _ImagePreviewPageState();
}

class _ImagePreviewPageState extends State<ImagePreviewPage> {
  late final PageController _pageController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _urlFor(FsObj img) {
    final client = OpenListClient(widget.site);
    final path = _join(widget.dirPath, img.name);
    return client.downloadUrl(path, sign: img.sign);
  }

  static String _join(String dir, String name) =>
      dir.endsWith('/') ? '$dir$name' : '$dir/$name';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          '${_index + 1} / ${widget.images.length} · '
          '${widget.images[_index].name}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: widget.images.length,
        builder: (context, i) {
          final img = widget.images[i];
          return PhotoViewGalleryPageOptions.customChild(
            child: Image.network(
              _urlFor(img),
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image,
                        size: 48, color: Colors.white54),
                    const SizedBox(height: 8),
                    Text(S.current.cannotPreview,
                        style: const TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            ),
            childSize: null,
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: img.name),
          );
        },
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        onPageChanged: (i) => setState(() => _index = i),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            widget.images[_index].name,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
