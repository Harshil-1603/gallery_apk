import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class FavoritesPage extends StatelessWidget {
  final Set<AssetEntity> favoritePhotos;

  FavoritesPage({required this.favoritePhotos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Favorites"),
      ),
      body: favoritePhotos.isEmpty
          ? Center(
              child: Text(
                "No Favorites Yet",
                style: TextStyle(color: Colors.white),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(4),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: favoritePhotos.length,
              itemBuilder: (context, index) {
                final photo = favoritePhotos.elementAt(index);

                return FutureBuilder<Uint8List?>(
                  future: photo.thumbnailDataWithSize(ThumbnailSize(200, 200)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    } else {
                      return Container(color: Colors.grey);
                    }
                  },
                );
              },
            ),
    );
  }
}
