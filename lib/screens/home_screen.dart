import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/block/image_block_provider.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/screens/detail_screen.dart';

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
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    CreateNewCollectionDialog(block: block),
              );
            },
            child: Icon(Icons.add_a_photo),
          )),
    );
  }

  Widget buildCollectionList(List<UIImageCollection> data, ImageBlock block) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          print("building upper list $index");
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(data[index].title.toUpperCase(),
                    style: Theme.of(context).textTheme.title),
                Divider(),
                buildImagesView(data, index, block),
              ],
            ),
          );
        });
  }

  Widget buildImagesView(
      List<UIImageCollection> data, int index, ImageBlock block) {
    return Wrap(
        spacing: 3,
        runSpacing: 3,
        children:
            List.generate(data[index].thumbnails.length + 1, (imageIndex) {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double size = (constraints.maxWidth - 6) / 3;
              return Container(
                  height: size,
                  width: size,
                  child: buildImageOrAddButton(imageIndex, data, index, block));
            },
          );
        }).toList());
  }

  Widget buildImageOrAddButton(int imageIndex, List<UIImageCollection> data,
      int index, ImageBlock block) {
    if (imageIndex == data[index].thumbnails.length) {
      return Material(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.grey.withOpacity(0.1),
          child: InkWell(
            onTap: () => block.addImage(data[index].id),
            child: Center(
              child: Icon(
                Icons.add_circle_outline,
                size: 36,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );
    } else {
      final collection = data[index];
      final imageFuture = collection.thumbnails[imageIndex];
      return FutureBuilder(
          future: imageFuture,
          builder: (context, AsyncSnapshot<Thumbnail> snapshot) {
            if (snapshot.hasData) {
              return GestureDetector(
                  onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return DetailPage(
                            collection.id, collection.uiImages[imageIndex]);
                      })),
                  onLongPress: () => block.deleteImage(snapshot.data.path),
                  child: Container(
                    child: Hero(
                        tag: snapshot.data.path,
                        child: Image.memory(snapshot.data.image,
                            fit: BoxFit.cover)),
                  ));
            } else {
              return Text("Loading");
            }
          });
    }
    ;
  }
}

class CreateNewCollectionDialog extends StatefulWidget {
  const CreateNewCollectionDialog({Key key, this.block}) : super(key: key);

  final ImageBlock block;

  @override
  _CreateNewCollectionDialogState createState() =>
      _CreateNewCollectionDialogState();
}

class _CreateNewCollectionDialogState extends State<CreateNewCollectionDialog> {
  var _title = "";

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      title: const Text(
        "CREATE NEW COLLECTION",
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54),
      ),
      contentPadding: EdgeInsets.all(16),
      children: <Widget>[
        Column(
          children: <Widget>[
            TextField(
              onChanged: (text) {
                setState(() {
                  _title = text;
                });
              },
              decoration: InputDecoration(
                labelText: "Title",
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: _title == ""
                    ? null
                    : () async {
                        final collectionId =
                            await widget.block.createCollection(_title);
                        widget.block.addImage(collectionId);
                        Navigator.of(context).pop();
                      },
                child: Text(
                  "ADD PHOTO",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
