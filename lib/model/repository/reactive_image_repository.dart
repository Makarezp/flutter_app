import 'dart:io';

import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'image_repository.dart';


abstract class ReactiveImageRepository {

  Observable<List<ImageCollection>> collections();

  Future<void> addImage(String imagePath, [String collectionId]);

  Future<void> deleteImage(String imagePath);

}

class ReactiveImageRepositoryImpl extends ReactiveImageRepository {
  final ImageRepository imageRepository;
  bool _loaded = false;

  final _subject = BehaviorSubject<List<ImageCollection>>();

  ReactiveImageRepositoryImpl(this.imageRepository);

  @override
  Future<void> addImage(String imagePath, [String collectionId]) async {
    await imageRepository.addImage(imagePath, collectionId);
    _loadCollections();
  }

  @override
  Future<void> deleteImage(String imagePath) async {
    await imageRepository.deleteImage(imagePath);
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
    final collections = await imageRepository.loadCollections();
    _subject.add(collections);
  }

}