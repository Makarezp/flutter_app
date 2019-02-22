import 'dart:async';
import 'dart:typed_data';

import 'package:photos_saver/photos_saver.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/model/repository/reactive_image_repository.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ImageBlock {
  final ReactiveImageRepository _repo;

  final Map<String, Future<Thumbnail>> _cache;

  final Observable<List<UIImageCollection>> _collections;

  ImageBlock(this._repo, this._cache)
      : _collections = _repo.collections().map((e) => e
            .map((i) => UIImageCollection.fromImageCollection(i, _cache))
            .toList());

  Observable<List<UIImageCollection>> get collections => _collections;

  Observable<UIImageCollection> getCollection(String id) {
    return collections
        .map((it) => it.firstWhere((collection) => collection.id == id));
  }

  Future<String> createCollection(String title) {
    return _repo.createCollection(title);
  }

  Future<void> addImage(String collectionId) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    var path = await PhotosSaver.saveFile(fileData: image.readAsBytesSync());
    _repo.addImage(path, collectionId);
  }

  Future<void> deleteImage(String path) async {
    await _repo.deleteImage(path);
  }
}

class UIImageCollection {
  final String id;

  final String title;

  final List<UIImageMeta> uiImages;

  final List<Future<Thumbnail>> thumbnails;

  UIImageCollection.fromImageCollection(
      ImageCollection collection, Map<String, Future<Thumbnail>> cache)
      : this.id = collection.id,
        this.uiImages =
            collection.images.map((img) => UIImageMeta(img.path)).toList(),
        this.title = collection.title,
        this.thumbnails = collection.images.map((img) {
          if (!cache.containsKey(img.path)) {
            cache[img.path] = FlutterImageCompress.compressWithFile(img.path,
                    minWidth: 400, minHeight: 400, quality: 90)
                .then(
                    (value) => Thumbnail(img.path, Uint8List.fromList(value)));
          }
          return cache[img.path];
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

class Thumbnail {
  final String path;

  final Uint8List image;

  Thumbnail(this.path, this.image);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Thumbnail &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}

class UIImageMeta {
  final String path;

  UIImageMeta(this.path);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UIImageMeta &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
