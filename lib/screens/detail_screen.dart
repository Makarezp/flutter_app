import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block_provider.dart';

class DetailPage extends StatefulWidget {
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    var block = ImageBlockProvider.of(context);

    return SafeArea(
      child: Scaffold(

      ),
    );
  }
}
