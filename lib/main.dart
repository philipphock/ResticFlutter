import 'package:flutter/material.dart';
import 'package:hello_world/views/ItemListView.dart';
import 'package:hello_world/views/ItemPrefs.dart';
import 'package:provider/provider.dart';

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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ItemPrefsModel()),
          ChangeNotifierProvider(create: (context) => ItemListModel())
        ],
        child: MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => ItemListView(),
              ItemPrefsView.ROUTE: (context) => ItemPrefsView()
            }));
  }
}
