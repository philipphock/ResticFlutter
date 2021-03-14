import 'package:flutter/material.dart';
import 'package:hello_world/comm.dart';
import 'package:hello_world/views/ItemListView.dart';
import 'package:hello_world/views/ItemPrefs.dart';

void main() {
  runApp(MyApp());
}

enum MainViews { ItemList, ItemPrefs }

class SwitchMainViewArgs {
  final MainViews view;
  final BuildContext context;
  SwitchMainViewArgs({this.view, this.context});
}

class MyApp extends StatelessWidget {
  static final ItemListView _itemListView = ItemListView(title: "My App");
  static void switchViewItemList(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => _itemListView));
  }

  static void switchViewItemPrefs(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ItemPrefsView()));
  }

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
