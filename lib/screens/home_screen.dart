import 'dart:io';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Camero"),
        ),
        body: Container(

        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => print("bydle"),
          child: Icon(Icons.add_a_photo),
        ));
  }
}
