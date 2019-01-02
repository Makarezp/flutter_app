import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';

abstract class ImageRepository {

  Future<void> addImage(String imagePath, [String collectionId]);

  Observable<List<ImageCollection>> collections();
}

