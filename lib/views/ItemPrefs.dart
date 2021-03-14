import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/views/ItemListView.dart';

class ItemPrefsView extends StatelessWidget {
  static const String ROUTE = "/prefs";
  @override
  Widget build(BuildContext context) {
    final ListItemModel item = ModalRoute.of(context).settings.arguments;
    print(item.heading);

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

class ItemPrefsModel extends ChangeNotifier {
  ItemPrefsModel() : super() {}
}
