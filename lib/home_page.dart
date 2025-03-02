import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';
import 'favorites_page.dart';
import 'settings_page.dart';
import 'image_viewer_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AssetEntity> allPhotos = [];
  List<AssetEntity> filteredPhotos = [];
  TextEditingController searchController = TextEditingController();
  int _currentIndex = 0;
  Set<AssetEntity> favoritePhotos = {}; // Store favorite images

  @override
  void initState() {
    super.initState();
    fetchPhotos();
  }

  Future<void> fetchPhotos() async {
    final PermissionState status = await PhotoManager.requestPermissionExtend();
    if (status.isAuth) {
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      List<AssetEntity> tempPhotos = [];

      for (var album in albums) {
        final List<AssetEntity> assets =
            await album.getAssetListPaged(page: 0, size: 100);
        tempPhotos.addAll(assets);
      }

      tempPhotos.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      setState(() {
        allPhotos = tempPhotos;
        filteredPhotos = List.from(allPhotos);
      });
    }
  }

  void filterPhotos(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPhotos = List.from(allPhotos);
      });
    } else {
      setState(() {
        filteredPhotos = allPhotos.where((photo) {
          String fileName = photo.title?.toLowerCase() ?? '';
          return fileName.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  void toggleFavorite(AssetEntity photo) {
    setState(() {
      if (favoritePhotos.contains(photo)) {
        favoritePhotos.remove(photo);
      } else {
        favoritePhotos.add(photo);
      }
    });
  }

  Widget getBody() {
    switch (_currentIndex) {
      case 1:
        return FavoritesPage(favoritePhotos: favoritePhotos);
      case 2:
        return SettingsPage();
      default:
        return buildGallery();
    }
  }

  Widget buildGallery() {
    return filteredPhotos.isEmpty
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
            padding: EdgeInsets.all(4),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: filteredPhotos.length,
            itemBuilder: (context, index) {
              final photo = filteredPhotos[index];

              return FutureBuilder<Uint8List?>(
                future: photo.thumbnailDataWithSize(ThumbnailSize(200, 200)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>ImageViewerPage(
                              images: allPhotos, // Pass all photos so user can swipe
                              initialIndex: index, // Start from the clicked image
                            ),
                          ),
                        );
                      },
                      onLongPress: () => toggleFavorite(photo),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                          ),
                          if (favoritePhotos.contains(photo))
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Icon(Icons.favorite, color: Colors.red),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return Container(color: Colors.grey);
                  }
                },
              );
            },
          );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Search photos...",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: filterPhotos,
        ),
      ),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: "Gallery",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
