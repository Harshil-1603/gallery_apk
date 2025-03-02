import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'image_viewer_page.dart';

class FolderDetailsPage extends StatelessWidget {
  final String folderName;
  final List<AssetEntity> photos;

  FolderDetailsPage({required this.folderName, required this.photos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(folderName, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(5),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewerPage(images: photos, initialIndex: index),
                ),
              );
            },
            child: FutureBuilder<Widget>(
              future: photos[index].thumbnailDataWithSize(ThumbnailSize(200, 200)).then(
                (data) => data != null
                    ? Image.memory(data, fit: BoxFit.cover)
                    : Container(color: Colors.grey),
              ),
              builder: (context, snapshot) {
                return snapshot.connectionState == ConnectionState.done
                    ? snapshot.data!
                    : Container(color: Colors.grey);
              },
            ),
          );
        },
      ),
    );
  }
}
