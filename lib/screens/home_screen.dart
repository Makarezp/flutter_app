import 'dart:io';
import 'dart:typed_data';

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

    return SafeArea(
      child: Scaffold(
          body: Container(
            child: StreamBuilder(
                stream: block.collections,
                builder:
                    (context, AsyncSnapshot<List<UIImageCollection>> snapshot) {
                  if (!snapshot.hasData) {
                    return Text("Loading");
                  }

                  return buildCollectionList(snapshot.data, block);
                }),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => block.addImage(),
            child: Icon(Icons.add_a_photo),
          )),
    );
  }

  Widget buildCollectionList(List<UIImageCollection> data, ImageBlock block) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          print("building upper list $index");
          return Column(
            children: <Widget>[
              Text("Title", style: Theme.of(context).textTheme.title),
              Container(height: 200, child: buildListView(data, index, block)),
            ],
          );
        });
  }

  ListView buildListView(
      List<UIImageCollection> data, int index, ImageBlock block) {
    return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data[index].thumbnails.length,
        itemBuilder: (context, imageIndex) {
          final imageFuture = data[index].thumbnails[imageIndex];
          print("building lower list  $imageIndex");
          return FutureBuilder(
              future: imageFuture,
              builder: (context, AsyncSnapshot<Thumbnail> snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () => print("Bydle"),
                      onDoubleTap: () =>
                          block.addImage(collectionId: data[index].id),
                      onLongPress: () =>
                      block.deleteImage(snapshot.data.path),
                      child: Container(
                        child: Image.memory(snapshot.data.image),
                      ));
                } else {
                  return Text("Loading");
                }
              });
        });
  }
}
