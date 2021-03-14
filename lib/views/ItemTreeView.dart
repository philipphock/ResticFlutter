import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/views/ItemListView.dart';

class ItemTreeView extends StatelessWidget {
  static const String ROUTE = "/tree";
  @override
  Widget build(BuildContext context) {
    final ListItemModel item = ModalRoute.of(context).settings.arguments;
    //print(item.heading);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tree"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
    );
  }
}

class ItemTreeModel extends ChangeNotifier {
  ItemTreeModel();
}
