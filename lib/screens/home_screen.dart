import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_saver/image_picker_saver.dart';

class HomeScreen extends StatefulWidget {

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  File imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Camero"),
        ),
        body: Container(
          child: imageFile != null ?
          Image.file(imageFile) : null,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          child: Icon(Icons.add_a_photo),
        ));
  }

  Future getImage() async {
    var image = await ImagePickerSaver.pickImage(source: ImageSource.camera);
    await ImagePickerSaver.saveFile(fileData: image.readAsBytesSync());
    setState(() {
      imageFile = image;
    });
  }
}
