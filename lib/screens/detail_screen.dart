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
  Uint8List previousPageCache;
  Uint8List nextPageCache;

  PageController pageController;

  _DetailPageState(
      this._collectionId, this._currImage, this.image, this.initCollection) {
    this.previousPageCache = image;
    this.nextPageCache = image;
  }

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
          final initPage = snapshot.data.uiImages.indexOf(_currImage);
          currPage = initPage;
          pageController = PageController(
            initialPage: initPage,
          );
          _collection = snapshot.data;
          return buildPageView(context, snapshot.data);
        });
  }

  PageView buildPageView(BuildContext context, UIImageCollection collection) {
    return PageView.builder(
        onPageChanged: (pageIndex) {
          currPage = pageIndex;
          _precache(pageIndex, context);
        },
        controller: pageController,
        itemCount: collection.uiImages.length,
        itemBuilder: (context, index) {
          _initialPrecache(index, context);
          return Hero(
            tag: _collection.uiImages[index].path,
            child: Container(
              width: 150,
              height: 150,
              child: _buildImageFuture(
                  File(collection.uiImages[index].path), index),
            ),
          );
        });
  }

  Widget _buildImageFuture(File file, int index) {
    final val = index > previousPage ? nextPageCache : previousPageCache;
    return FutureBuilder(
      key: Key("futurebuilder"),
      future: file.readAsBytes(),
      initialData: image,
      builder: (context, snapshot) {
        return Image.memory(snapshot.data, fit: BoxFit.cover);
      },
    );
  }

  void _initialPrecache(int currIndex, BuildContext context) {
    if (previousPage == -1) {
      _precachePreviousPage(currIndex, context);
      _precacheNextPage(currIndex, context);
      previousPage = currIndex;
    }
  }

  void _precache(int currIndex, BuildContext context) {
    if (currIndex > previousPage) {
      _precacheNextPage(currIndex, context);
    } else if (currIndex < previousPage) {
      _precachePreviousPage(currIndex, context);
    }
    previousPage = currIndex;
  }

  void _precacheNextPage(int currIndex, BuildContext context) {
    if (currIndex < _collection.uiImages.length - 1) {
      precacheImage(
          FileImage(File(_collection.uiImages[currIndex + 1].path)), context);
      Future.value(_collection.thumbnails[currIndex + 1]).then((thumbNail) {
        nextPageCache = thumbNail.image;
      });
    }
  }

  void _precachePreviousPage(int currIndex, BuildContext context) {
    if (currIndex > 0) {
      precacheImage(
          FileImage(File(_collection.uiImages[currIndex - 1].path)), context);

      Future.value(_collection.thumbnails[currIndex - 1]).then((thumbNail) {
        previousPageCache = thumbNail.image;
      });
    }
  }
}
