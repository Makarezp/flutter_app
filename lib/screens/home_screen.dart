import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/block/image_block_provider.dart';
import 'package:timeline_app/model/image_collection.dart';

class HomeScreen extends StatefulWidget {
  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var block = ImageBlockProvider.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Camero"),
        ),
        body: Container(
          child: StreamBuilder(
              stream: block.collections,
              builder:
                  (context, AsyncSnapshot<List<ImageCollection>> snapshot) {
                if (!snapshot.hasData) {
                  return Text("Loading");
                }

                return buildCollectionList(snapshot.data, block);
              }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => block.addImage(),
          child: Icon(Icons.add_a_photo),
        ));
  }

  Widget buildCollectionList(List<ImageCollection> data, ImageBlock block) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              Text("Title", style: Theme.of(context).textTheme.title),
              Container(
                  height: 200,
                  child: buildListView(data, index, block)),
            ],
          );
        });
  }

  ListView buildListView(List<ImageCollection> data, int index,
      ImageBlock block) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data[index].images.length,
        itemBuilder: (context, imageIndex) {
          return GestureDetector(
            onDoubleTap: () =>
                block.addImage(collectionId: data[index].id),
            child: Container(
              child: Image.file(File(data[index].images[imageIndex]),
                fit: BoxFit.contain,
                height: 200,),
            ),
          );
        });
  }
}
