import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'folder_details_page.dart';

class FolderPage extends StatefulWidget {
  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  Map<String, List<AssetEntity>> folders = {};

  @override
  void initState() {
    super.initState();
    fetchFolders();
  }

  Future<void> fetchFolders() async {
    final PermissionState status = await PhotoManager.requestPermissionExtend();
    if (status.isAuth) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(type: RequestType.all);
      
      Map<String, List<AssetEntity>> tempFolders = {};

      for (var album in albums) {
        final List<AssetEntity> assets = await album.getAssetListPaged(page: 0, size: 50);
        if (assets.isNotEmpty) {
          tempFolders[album.name] = assets;
        }
      }

      setState(() {
        folders = tempFolders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Folders', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: folders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: folders.entries.map((entry) {
                return ListTile(
                  leading: FutureBuilder<Widget>(
                    future: entry.value.first.thumbnailDataWithSize(ThumbnailSize(100, 100)).then(
                      (data) => data != null ? Image.memory(data, fit: BoxFit.cover) : Container(color: Colors.grey),
                    ),
                    builder: (context, snapshot) {
                      return snapshot.connectionState == ConnectionState.done
                          ? snapshot.data!
                          : Container(width: 50, height: 50, color: Colors.grey);
                    },
                  ),
                  title: Text(entry.key, style: TextStyle(color: Colors.white)),
                  subtitle: Text('${entry.value.length} items', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FolderDetailsPage(
                          folderName: entry.key,
                          photos: entry.value,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
    );
  }
}
