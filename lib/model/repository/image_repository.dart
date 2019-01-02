import 'package:timeline_app/model/image_collection.dart';

abstract class ImageRepository {

  Future<void> addImage(String imagePath, [String collectionId]);

  Future<List<ImageCollection>> loadCollections();
}

