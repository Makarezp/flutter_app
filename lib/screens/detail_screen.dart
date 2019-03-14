import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/block/image_block_provider.dart';

class DetailPage extends StatefulWidget {
  final String collectionId;
  final UIImageMeta initImageMeta;
  final UIImageCollection initCollection;

  DetailPage(this.collectionId, this.initImageMeta, this.initCollection);

  @override
  _DetailPageState createState() =>
      _DetailPageState(collectionId, initImageMeta, initCollection);
}

class _DetailPageState extends State<DetailPage> {
  UIImageMeta _currImage;
  String _collectionId;
  ImageBlock _block;
  UIImageCollection _collection;
  StreamSubscription _sub;
  int currPage = -1;
  UIImageCollection initCollection;
  List<Uint8List> images = [];
  bool tapingUpperContainer = false;

  PageController pageController;
  PageController lowerPageController;

  _DetailPageState(this._collectionId, this._currImage, this.initCollection);

  @override
  void didChangeDependencies() {
    _block = ImageBlockProvider.of(context);
    init(initCollection);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(body: buildPage(context)),
    );
  }

  Widget buildPage(BuildContext context) {
    return StreamBuilder(
        stream: _block.getCollection(_collectionId),
        initialData: initCollection,
        builder: (context, AsyncSnapshot<UIImageCollection> snapshot) {
          return Column(
            children: <Widget>[
              Expanded(
                child: _buildUpperViewPager(context, snapshot.data),
              ),
              _buildLowerViewPager(snapshot)
            ],
          );
        });
  }

  void init(UIImageCollection collection) {
    final initPage = collection.uiImages.indexOf(_currImage);
    currPage = initPage;
    pageController = PageController(
      initialPage: initPage,
    );
    lowerPageController = PageController(
      viewportFraction: 0.25,
      initialPage: initPage,
    );
    _collection = collection;
    Future.forEach(_collection.thumbnails, (Future<Thumbnail> thumbnail) {
      thumbnail.then((val) {
        images.add(val.image);
      });
    });
  }

  Widget _buildUpperViewPager(
      BuildContext context, UIImageCollection collection) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragDown: (drag) {
        tapingUpperContainer = true;
      },
      child: PageView.builder(
          onPageChanged: onUpperPageChanged,
          controller: pageController,
          itemCount: collection.uiImages.length,
          itemBuilder: (context, index) {
            return Hero(
              tag:
                  currPage == index ? _collection.uiImages[index].path : "null",
              child: Container(
                width: 150,
                height: 150,
                child: _buildImageFuture(
                    File(collection.uiImages[index].path), index),
              ),
            );
          }),
    );
  }

  void onUpperPageChanged(pageIndex) {
    if (tapingUpperContainer) {
      lowerPageController.animateToPage(pageIndex,
          duration: Duration(milliseconds: 300), curve: Curves.linear);
    }
  }

  Container _buildLowerViewPager(AsyncSnapshot<UIImageCollection> snapshot) {
    return Container(
      height: 100,
      child: GestureDetector(
        onHorizontalDragDown: (drag) {
          tapingUpperContainer = false;
        },
        child: PageView.builder(
            pageSnapping: false,
            scrollDirection: Axis.horizontal,
            onPageChanged: onLowerPageChanged,
            controller: lowerPageController,
            itemCount: snapshot.data.uiImages.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  lowerPageController.animateToPage(index,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.linear);
                },
                child: Container(
                  width: 100,
                  decoration: currPage == index
                      ? BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 4),
                        )
                      : null,
                  child: Image.memory(images[index],
                      fit: BoxFit.cover, gaplessPlayback: true),
                ),
              );
            }),
      ),
    );
  }

  void onLowerPageChanged(index) {
    pageController.animateToPage(index,
        duration: Duration(milliseconds: 1), curve: Curves.linear);
    setState(() {
      currPage = index;
    });
  }

  Widget _buildImageFuture(File file, int index) {
    return FutureBuilder(
      future: precacheImage(FileImage(file), context).then((val) => true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Image.memory(images[index],
              fit: BoxFit.cover, gaplessPlayback: true);
        }
        return Image.file(
          file,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      },
    );
  }
}
