import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/model/repository/image_repository.dart';

class LocalImageRepository implements ImageRepository {
  final Future<String> Function() _getPath;

  LocalImageRepository(this._getPath);

  @override
  Future<void> addImage(String imagePath, [String collectionId]) async {
    final file = await _getLocalFile();
    List<Map<String, dynamic>> jsonMap;
    final fileExists = await file.exists();
    if(fileExists) {
      final string = await file.readAsString();
      jsonMap = JsonDecoder().convert(string)["collection"];
    }
    if (jsonMap == null) {
      jsonMap = List<Map<String, dynamic>>();
    }
    List<ImageCollection> collections = jsonMap
        .map<ImageCollection>((it) => ImageCollection.fromJson(it))
        .toList();
    if (collectionId != null) {
      collections = collections.map((it) {
        if (it.id == collectionId) {
          it.images.add(imagePath);
        }
        return it;
      }).toList();
    } else {
      final imageCollection = ImageCollection(Uuid().v1(), [imagePath]);
      collections = collections..add(imageCollection);
    }

    final collectionsJson = JsonEncoder()
        .convert({"collection": collections.map((e) => e.toJson()).toList()});
    return file.writeAsString(collectionsJson);
  }

  @override
  Observable<List<ImageCollection>> collections() {
    return Observable.just([]);
  }

  Future<File> _getLocalFile() async {
    var path = await _getPath();
    return File(path);
  }
}
