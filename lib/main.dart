import 'package:flutter/material.dart';
import 'package:hello_world/comm.dart';
import 'package:hello_world/views/ItemEditView.dart';
import 'package:hello_world/views/ItemListView.dart';
import 'package:hello_world/views/ItemPrefsView.dart';
import 'package:hello_world/views/ItemTreeView.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ItemPrefsModel()),
          ChangeNotifierProvider(create: (context) => ItemListModel()),
          ChangeNotifierProvider(create: (context) => ItemEditModel())
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            routes: {
              ItemListView.ROUTE: (context) => ItemListView(),
              ItemPrefsView.ROUTE: (context) => ItemPrefsView(),
              ItemEditView.ROUTE: (context) => ItemEditView(),
              ItemTreeView.ROUTE: (context) => ItemTreeView(),
            }));
  }
}
