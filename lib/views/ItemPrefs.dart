import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemPrefsView extends StatefulWidget {
  ItemPrefsView({Key key}) : super(key: key);

  @override
  ItemPrefsViewState createState() => ItemPrefsViewState();
}

class ItemPrefsViewState extends State<ItemPrefsView> {
  ItemPrefsViewState() : super() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Title"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
    );
  }
}
