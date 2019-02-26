import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/block/image_block_provider.dart';

class DetailPage extends StatefulWidget {
  final String collectionId;
  final UIImageMeta initImageMeta;
  final Uint8List image;
  final UIImageCollection initCollection;

  DetailPage(
      this.collectionId, this.initImageMeta, this.image, this.initCollection);

  @override
  _DetailPageState createState() =>
      _DetailPageState(collectionId, initImageMeta, image, initCollection);
}

class _DetailPageState extends State<DetailPage> {
  UIImageMeta _currImage;
  String _collectionId;
  ImageBlock _block;
  UIImageCollection _collection;
  StreamSubscription _sub;
  int previousPage = -1;
  int currPage = -1;
  Uint8List image;
  UIImageCollection initCollection;
  List<Uint8List> images = [];
  bool tapingUpperContainer = false;

  PageController pageController;
  PageController lowerPageController;

  _DetailPageState(
      this._collectionId, this._currImage, this.image, this.initCollection);

  @override
  void didChangeDependencies() {
    _block = ImageBlockProvider.of(context);
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            final initPage = snapshot.data.uiImages.indexOf(_currImage);
            currPage = initPage;
            pageController = PageController(
              initialPage: initPage,
            );
            lowerPageController = PageController(
              viewportFraction: 0.25,
              initialPage: initPage,
            );
            _collection = snapshot.data;
            Future.forEach(_collection.thumbnails,
                (Future<Thumbnail> thumbnail) {
              thumbnail.then((val) {
                images.add(val.image);
              });
            });
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: buildPageView(context, snapshot.data),
              ),
              Container(
                height: 100,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragDown: (drag) {
                    tapingUpperContainer = false;
                  },
                  child: PageView.builder(
                      pageSnapping: false,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index) {
                        pageController.animateToPage(index,
                            duration: Duration(milliseconds: 1),
                            curve: Curves.linear);
                      },
                      controller: lowerPageController,
                      itemCount: snapshot.data.uiImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          width: 100,
                          child: Image.memory(images[index],
                              fit: BoxFit.cover, gaplessPlayback: true),
                        );
                      }),
                ),
              )
            ],
          );
        });
  }

  Widget buildPageView(BuildContext context, UIImageCollection collection) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragDown: (drag) {
        tapingUpperContainer = true;
      },
      child: PageView.builder(
          onPageChanged: (pageIndex) {
            currPage = pageIndex;
            if (tapingUpperContainer) {
              lowerPageController.animateToPage(pageIndex,
                  duration: Duration(milliseconds: 300), curve: Curves.linear);
            }
          },
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
