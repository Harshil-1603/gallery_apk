import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerPage extends StatefulWidget {
  final List<AssetEntity> images;
  final int initialIndex;

  ImageViewerPage({required this.images, required this.initialIndex});

  @override
  _ImageViewerPageState createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<MemoryImage?> getImageProvider(AssetEntity asset) async {
    final file = await asset.originBytes;
    if (file != null) {
      return MemoryImage(file);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.images.length,
        pageController: _pageController,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions.customChild(
            child: FutureBuilder<MemoryImage?>(
              future: getImageProvider(widget.images[index]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                  return Image(image: snapshot.data!);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
      ),
    );
  }
}
