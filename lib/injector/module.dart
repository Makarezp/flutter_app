import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/model/repository/local_image_repository.dart';
import 'package:timeline_app/model/repository/reactive_image_repository.dart';

class ReactiveImageRepositorySingleton {
  static final ReactiveImageRepositorySingleton _singleton =
      ReactiveImageRepositorySingleton._internal(repo: (){
        var getPath = () => getApplicationDocumentsDirectory()
            .then((val) => join(val.path, "Timeline.json"));
        var localImageRepository = LocalImageRepository(getPath);
        return ReactiveImageRepositoryImpl(localImageRepository);
      }());

  final ReactiveImageRepository repo;

  factory ReactiveImageRepositorySingleton() {
    return _singleton;
  }

  ReactiveImageRepositorySingleton._internal({@required this.repo});
}

ImageBlock provideImageBlock() {
  return ImageBlock(ReactiveImageRepositorySingleton().repo, {});
}