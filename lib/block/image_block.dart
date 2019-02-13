import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/model/repository/reactive_image_repository.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageBlock {
  final ReactiveImageRepository _repo;

  final Map<String, Future<Uint8List>> _cache;

  final Observable<List<UIImageCollection>> _collections;

  ImageBlock(this._repo, this._cache) :
    _collections = _repo.collections().map((e) => e
        .map((i) => UIImageCollection.fromImageCollection(i, _cache))
    .toList());

  Observable<List<UIImageCollection>> get collections => _collections;

  Future<void> addImage({String collectionId}) async {
    var image = await ImagePickerSaver.pickImage(source: ImageSource.camera);
    var path =
        await ImagePickerSaver.saveFile(fileData: image.readAsBytesSync());
    _repo.addImage(path, collectionId);
  }

  Future<void> deleteImage(String path) async {
    await _repo.deleteImage(path);
  }
}

class UIImageCollection {
  final String id;

  final List<Future<Uint8List>> thumbnails;

  UIImageCollection.fromImageCollection(
      ImageCollection collection, Map<String, Future<Uint8List>> cache)
      : this.id = collection.id,
        this.thumbnails = collection.images.map((path) {
          if (!cache.containsKey(path)) {
            cache[path] = FlutterImageCompress.compressWithFile(path,
                minWidth: 1000, minHeight: 1000, quality: 90)
                .then((value) => Uint8List.fromList(value));
          }
          return cache[path];
        }).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UIImageCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          thumbnails == other.thumbnails;

  @override
  int get hashCode => id.hashCode ^ thumbnails.hashCode;
}
