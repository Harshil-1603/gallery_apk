import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewerPage extends StatefulWidget {
  final List<AssetEntity> images;
  final int initialIndex;

  const ImageViewerPage({Key? key, required this.images, required this.initialIndex}) : super(key: key);

  @override
  _ImageViewerPageState createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  List<Uint8List?> imageData = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    List<Uint8List?> tempData = [];
    for (var image in widget.images) {
      Uint8List? data = await image.thumbnailDataWithSize(ThumbnailSize(1000, 1000));
      tempData.add(data);
    }
    setState(() {
      imageData = tempData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: imageData.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader until images are loaded
          : PhotoViewGallery.builder(
              itemCount: widget.images.length,
              pageController: PageController(initialPage: widget.initialIndex),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: MemoryImage(imageData[index]!),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index].id),
                );
              },
              scrollPhysics: BouncingScrollPhysics(),
            ),
    );
  }
}
