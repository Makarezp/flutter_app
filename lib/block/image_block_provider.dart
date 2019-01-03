import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';

class ImageBlockProvider extends InheritedWidget {
  final ImageBlock block;

  ImageBlockProvider({Key key, @required this.block, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static ImageBlock of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(ImageBlockProvider)
              as ImageBlockProvider)
          .block;
}
