import 'package:timeline_app/model/image_collection.dart';

abstract class ImageRepository {

  Future<String> createCollection(String title);

  Future<void> addImage(String imagePath, String collectionId);

  Future<List<ImageCollection>> loadCollections();

  Future<void> deleteImage(String path);
}

