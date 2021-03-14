import 'package:flutter/material.dart';
import 'package:hello_world/ItemListView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: ItemListView(title: 'Flutter Demo Home Page'),
    );
  }
}
