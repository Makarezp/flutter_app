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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Title", style: Theme.of(context).textTheme.title),
              buildImagesView(data, index, block),
            ],
          );
        });
  }

  Widget buildImagesView(
      List<UIImageCollection> data, int index, ImageBlock block) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
          spacing: 3,
          runSpacing: 3,
          children: List.generate(data[index].thumbnails.length, (imageIndex) {
            final imageFuture = data[index].thumbnails[imageIndex];
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double size = (constraints.maxWidth - 6) / 3;
                return Container(
                  height: size,
                  width: size,
                  child: FutureBuilder(
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
                                child: Image.memory(snapshot.data.image,
                                    fit: BoxFit.cover),
                              ));
                        } else {
                          return Text("Loading");
                        }
                      }),
                );
              },
            );
          }).toList()),
    );
  }
}
