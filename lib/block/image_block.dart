import 'package:rxdart/rxdart.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/model/repository/reactive_image_repository.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

class ImageBlock {
  final ReactiveImageRepository _repo;

  final Observable<List<ImageCollection>> _collections;

  ImageBlock(this._repo) :
      _collections = _repo.collections();

  Observable<List<ImageCollection>> get collections => _collections;

  Future<void> addImage({String collectionId}) async {
    var image = await ImagePickerSaver.pickImage(source: ImageSource.camera);
    var path = await ImagePickerSaver.saveFile(fileData: image.readAsBytesSync());
    _repo.addImage(path, collectionId);
  }

  Future<void> deleteImage(String path) async {
    await _repo.deleteImage(path);
  }
}