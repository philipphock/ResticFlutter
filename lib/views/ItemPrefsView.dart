import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restic_ui/models/ItemListModel.dart';

class ItemPrefsView extends StatelessWidget {
  static const String ROUTE = "/prefs";
  @override
  Widget build(BuildContext context) {
    final ListItemModel item = ModalRoute.of(context).settings.arguments;
    print(item.heading);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inspect"),
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
