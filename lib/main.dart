import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block_provider.dart';
import 'package:timeline_app/injector/module.dart';
import 'package:timeline_app/screens/home_screen.dart';

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
}
