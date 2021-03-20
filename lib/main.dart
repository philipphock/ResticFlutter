import 'package:flutter/material.dart';
import 'package:restic_ui/views/ErrorLogView.dart';
import 'package:restic_ui/views/ItemEditView.dart';
import 'package:restic_ui/views/ItemListView.dart';
import 'package:restic_ui/views/ItemPrefsView.dart';
import 'package:restic_ui/views/ItemTreeView.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ItemListModel()),
          //ChangeNotifierProvider(create: (context) => ItemEditModel())
        ],
        child: MaterialApp(
            title: 'Restic UI',
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
              ErrorLogView.ROUTE: (context) => ErrorLogView()
            }));
  }
}
