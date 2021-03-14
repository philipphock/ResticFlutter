import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/views/ItemListView.dart';

class ItemEditView extends StatelessWidget {
  static const String ROUTE = "/edit";
  @override
  Widget build(BuildContext context) {
    final ListItemModel item = ModalRoute.of(context).settings.arguments;
    //print(item.heading);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
    );
  }
}

class ItemEditModel extends ChangeNotifier {
  ItemEditModel();
}
