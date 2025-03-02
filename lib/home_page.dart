import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, List<AssetEntity>> sortedPhotos = {};

  @override
  void initState() {
    super.initState();
    fetchSortedPhotos();
  }

  Future<void> fetchSortedPhotos() async {
    final PermissionState status = await PhotoManager.requestPermissionExtend();
    if (status.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      List<AssetEntity> allPhotos = [];

      for (var album in albums) {
        final List<AssetEntity> assets = await album.getAssetListPaged(page: 0, size: 100);
        allPhotos.addAll(assets);
      }

      // Sorting by date (newest first)
      allPhotos.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      // Grouping by date
      Map<String, List<AssetEntity>> tempSortedPhotos = {};
      for (var photo in allPhotos) {
        String dateKey = "${photo.createDateTime.year}-${photo.createDateTime.month}-${photo.createDateTime.day}";
        if (!tempSortedPhotos.containsKey(dateKey)) {
          tempSortedPhotos[dateKey] = [];
        }
        tempSortedPhotos[dateKey]!.add(photo);
      }

      setState(() {
        sortedPhotos = tempSortedPhotos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: sortedPhotos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: sortedPhotos.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        entry.key, // Date heading
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Widget>(
                          future: entry.value[index].thumbnailDataWithSize(ThumbnailSize(200, 200)).then(
                                (data) => data != null ? Image.memory(data, fit: BoxFit.cover) : Container(color: Colors.grey),
                              ),
                          builder: (context, snapshot) {
                            return snapshot.connectionState == ConnectionState.done
                                ? snapshot.data!
                                : Container(color: Colors.grey);
                          },
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }
}
