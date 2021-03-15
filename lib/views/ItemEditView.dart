import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/views/ItemListView.dart';

enum Operation { EDIT, NEW }

class ItemEditViewArgs {
  final Operation op;
  final ListItemModel model;
  ItemEditViewArgs(this.model, this.op);
  ItemEditViewArgs.edit(ListItemModel m) : this(m, Operation.EDIT);
  ItemEditViewArgs.create() : this(null, Operation.NEW);
}

class ItemEditView extends StatelessWidget {
  static const String ROUTE = "/edit";
  @override
  Widget build(BuildContext context) {
    final ItemEditViewArgs args = ModalRoute.of(context).settings.arguments;
    if (args.op == Operation.NEW) {
      print("NEW");
    } else {
      print("EDIT");
    }
    //print(item.heading);

    return Scaffold(
      appBar: AppBar(
          title: const Text("Edit"),
          iconTheme: IconThemeData(
            color: Colors.white70, //change your color here
          ),
          leading: IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () =>
                  Navigator.pop(context, new ListItemModel("heading")))),
    );
  }
}

class ItemEditModel extends ChangeNotifier {
  ItemEditModel();
}
