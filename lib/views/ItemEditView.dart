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

class ItemEditView extends StatefulWidget {
  static const String ROUTE = "/edit";
  const ItemEditView({Key key}) : super(key: key);

  @override
  ItemEditState createState() => ItemEditState();
}

class ItemEditState extends State<ItemEditView> {
  String _title = "New repo";

  String get title => _title;
  set title(String value) {
    setState(() {
      _title = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ItemEditViewArgs args = ModalRoute.of(context).settings.arguments;
    if (args.op == Operation.NEW) {
      title = "New repo";
    } else {
      title = "Edit repo";
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(child: Text("Hello"))),
          Container(
            child: Text("bottom"),
            constraints: BoxConstraints(maxHeight: 50, minHeight: 50),
          )
        ],
      )
      /*
      Padding(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Source'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Password'),
            ),
            Row(
              children: [
                Flexible(
                    child: TextFormField(
                  decoration: InputDecoration(labelText: 'Snapshots to keep'),
                )),
                Flexible(child: Text("Save password")),
                Flexible(
                    child: Checkbox(
                  value: true,
                ))
              ],
            ),
          ]))*/
      ,
      appBar: AppBar(
          title: Text(title),
          actions: [IconButton(icon: Icon(Icons.save))],
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
