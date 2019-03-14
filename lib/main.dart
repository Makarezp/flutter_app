import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block_provider.dart';
import 'package:timeline_app/injector/module.dart';
import 'package:timeline_app/screens/home_screen.dart';
import 'package:flutter/foundation.dart';

void main() {
  debugPrintHitTestResults = true;
  debugPrintGestureArenaDiagnostics = true;
  CustomWidgetFlutterBinding();
  runApp(App());
}

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
}

class CustomWidgetFlutterBinding extends WidgetsFlutterBinding {

  @override
  ImageCache createImageCache() {
    return CustomImageCache();
  }
}

class CustomImageCache extends ImageCache {


  @override
  ImageStreamCompleter putIfAbsent(Object key, ImageStreamCompleter loader(),
      {ImageErrorListener onError}) {
    debugPrint("putting $key");
    if(key is MemoryImage) {
      return super.putIfAbsent(key, loader, onError: onError);
    }
    return loader();
  }
}


