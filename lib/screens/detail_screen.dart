import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timeline_app/block/image_block.dart';
import 'package:timeline_app/block/image_block_provider.dart';

class DetailPage extends StatefulWidget {
  final String collectionId;
  final UIImageMeta initImageMeta;

  DetailPage(this.collectionId, this.initImageMeta);

  @override
  _DetailPageState createState() =>
      _DetailPageState(collectionId, initImageMeta);
}

class _DetailPageState extends State<DetailPage> {
  UIImageMeta _currImage;
  String _collectionId;
  ImageBlock _block;
  UIImageCollection _collection;
  StreamSubscription _sub;
  int previousPage = -1;

  PageController pageController;

  _DetailPageState(this._collectionId, this._currImage);

  @override
  void didChangeDependencies() {
    _block = ImageBlockProvider.of(context);
    _sub = _block.getCollection(_collectionId).listen((collection) {
      setState(() {
        pageController = PageController(
          initialPage: collection.uiImages.indexOf(_currImage),
        );
        _collection = collection;
      });
    });
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
      child: Scaffold(
          body: _collection != null
              ? PageView.builder(
                  onPageChanged: (pageIndex) {
                    _precache(pageIndex, context);
                  },
                  controller: pageController,
                  itemCount: _collection.uiImages.length,
                  itemBuilder: (context, index) {
                    _initialPrecache(index, context);
                    return Center(
                      child: Image.file(File(_collection.uiImages[index].path)),
                    );
                  })
              : CircularProgressIndicator()),
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
    }
  }

  void _precachePreviousPage(int currIndex, BuildContext context) {
    if (currIndex > 0) {
      precacheImage(
          FileImage(File(_collection.uiImages[currIndex - 1].path)), context);
    }
  }
}
