import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'image_repository.dart';


abstract class ReactiveImageRepository {

  Observable<List<ImageCollection>> collections();

  Future<String> createCollection(String title);

  Future<void> addImage(String imagePath, String collectionId);

  Future<void> deleteImage(String imagePath);

}

class ReactiveImageRepositoryImpl extends ReactiveImageRepository {
  final ImageRepository _imageRepository;
  bool _loaded = false;

  final _subject = BehaviorSubject<List<ImageCollection>>();

  ReactiveImageRepositoryImpl(this._imageRepository);


  @override
  Future<String> createCollection(String title) {
    return _imageRepository.createCollection(title);
  }

  @override
  Future<void> addImage(String imagePath, String collectionId) async {
    await _imageRepository.addImage(imagePath, collectionId);
    _loadCollections();
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    await _imageRepository.deleteImage(imagePath);
    await File(imagePath).delete();
    _loadCollections();
  }

  @override
  Observable<List<ImageCollection>> collections() {
    if(!_loaded) {
      _loadCollections();
    }
    return _subject.stream;
  }

  _loadCollections() async {
    final collections = await _imageRepository.loadCollections();
    _subject.add(collections);
  }

}