import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/model/repository/image_repository.dart';

class LocalImageRepository implements ImageRepository {
  final Future<String> Function() _getPath;

  LocalImageRepository(this._getPath);

  @override
  Future<void> addImage(String imagePath, [String collectionId]) async {
    final file = await _getLocalFile();

    final string = await file.readAsString();
    List<Map<String, dynamic>> jsonMap = JsonDecoder()
        .convert(string)["collection"]
        .cast<Map<String, dynamic>>();

    //map items to model
    List<ImageCollection> collections = jsonMap
        .map<ImageCollection>((it) => ImageCollection.fromJson(it))
        .toList();
    //if collectionId provided add to existing collection
    if (collectionId != null) {
      collections = collections.map((it) {
        if (it.id == collectionId) {
          it.images.add(imagePath);
        }
        return it;
      }).toList();
    } else {
      //create new collection
      final imageCollection = ImageCollection(Uuid().v1(), [imagePath]);
      collections = collections..add(imageCollection);
    }

    final collectionsJson = JsonEncoder()
        .convert({"collection": collections.map((e) => e.toJson()).toList()});
    return file.writeAsString(collectionsJson);
  }

  @override
  Future<List<ImageCollection>> loadCollections() async {
    final file = await _getLocalFile();
    final string = await file.readAsString();
    var jsonMap = JsonDecoder()
        .convert(string)["collection"]
        .cast<Map<String, dynamic>>();
    return jsonMap
        .map<ImageCollection>((it) => ImageCollection.fromJson(it))
        .toList();
  }

  Future<File> _getLocalFile() async {
    var path = await _getPath();
    var file = File(path);
    final bool doesFileExist = await file.exists();
    if (!doesFileExist) {
      await file.writeAsString(
          JsonEncoder().convert({"collection": List<Map<String, dynamic>>()}));
    }
    return file;
  }
}
