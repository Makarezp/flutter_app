// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:timeline_app/model/image_collection.dart';
import 'package:timeline_app/model/repository/image_repository.dart';
import 'package:timeline_app/model/repository/local_image_repository.dart';

void main() {
  File file;
  ImageRepository repository;

  setUp(() {
    var filePath = join(Directory.current.path, "test", "TimeLine.json");
    file = File(filePath);
    repository = LocalImageRepository(() => Future.value(filePath));
  });

  tearDown(() {
    file.exists().then((val) {
      if (val) {
        file.deleteSync();
      }
    });
  });

  test("adding image path to existing collection", () async {
    //given
    var firstCollection = ImageCollection("bffdf", ["file1", "file2"]);
    var str = JsonEncoder().convert({
      "collection": [firstCollection.toJson()]
    });
    await file.writeAsString(str);

    //when
    await repository.addImage("file3", "bffdf");

    //then
    List<ImageCollection> fileContents =
        jsonDecode(file.readAsStringSync())["collection"]
            .map<ImageCollection>((it) => ImageCollection.fromJson(it))
            .toList();
    var paths = fileContents.first.images;
    expect(paths.contains("file3"), true);
  });

  test("if image collection doesn't exist create one and add image to it", () async {
    //when
    await repository.addImage("file3");

    //then
    List<ImageCollection> fileContents =
    jsonDecode(file.readAsStringSync())["collection"]
        .map<ImageCollection>((it) => ImageCollection.fromJson(it))
        .toList();
    var paths = fileContents.first.images;
    expect(paths.contains("file3"), true);
  });
}
