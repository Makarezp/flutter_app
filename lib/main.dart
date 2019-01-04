import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/block/image_block_provider.dart';
import 'package:timeline_app/model/repository/local_image_repository.dart';
import 'package:timeline_app/model/repository/reactive_image_repository.dart';
import 'package:timeline_app/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ImageBlockProvider(
        block: provideImageBlock(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: HomeScreen(),
        ));
  }

  ImageBlock provideImageBlock() {
    var getPath = () => getApplicationDocumentsDirectory()
        .then((val) => join(val.path, "Timeline.json"));
    var localImageRepository = LocalImageRepository(getPath);
    var reactiveRepository = ReactiveImageRepositoryImpl(localImageRepository);
    return ImageBlock(reactiveRepository, {});
  }
}
