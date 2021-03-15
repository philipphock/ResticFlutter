import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/views/ItemListView.dart';
import 'package:hello_world/views/dialog.dart';

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
  ListItemModel ret;

  String get title => _title;
  set title(String value) {
    setState(() {
      _title = value;
    });
  }

  void save() {
    Navigator.pop(context, ret);
  }

  @override
  Widget build(BuildContext context) {
    final ItemEditViewArgs args = ModalRoute.of(context).settings.arguments;
    if (args.op == Operation.NEW) {
      title = "New repo";
      if (ret == null) {
        ret = ListItemModel(heading: "");
        ret.source.add(TextEditingController(text: "c:/"));
      }
    } else {
      title = "Edit repo";
    }

    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 14),
              Text("Sources", style: TextStyle(fontSize: 19)),
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: ret.source.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(children: [
                    Expanded(
                        child: TextFormField(
                      controller: ret.source[index],
                      decoration: InputDecoration(labelText: 'Source path'),
                    )),
                    IconButton(
                        icon: Icon(Icons.folder_open),
                        onPressed: () => setState(() async {
                              var p = await FilesystemPicker.open(
                                  context: context,
                                  fsType: FilesystemType.folder,
                                  rootDirectory: Directory.fromUri(Uri.file(
                                      ret.source[index].text,
                                      windows: Platform.isWindows)));
                              if (p != null) {
                                ret.source[index].text = p;
                              }
                            })),
                    IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => setState(
                            () => ret.source.remove(ret.source[index])))
                  ]);
                },
              ),
              IconButton(
                  onPressed: () {
                    setState(() {
                      ret.source.add(TextEditingController(text: ""));
                    });
                  },
                  icon: Icon(Icons.add)),
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
                    onChanged: (bool value) {},
                  ))
                ],
              ),
            ])),
        appBar: AppBar(
            title: Text(title),
            actions: [
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Save"),
                onPressed: save,
              )
            ],
            iconTheme: IconThemeData(
              color: Colors.white70, //change your color here
            ),
            leading: IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () async {
                  var r = await MyDialog.showAlertDialog(
                      context, "Warning", "Leave without saving?", [
                    DialogOption<int>("yes, discard", 0),
                    DialogOption<int>("no, save item", 1)
                  ]);
                  if (r == 0) {
                    Navigator.pop(context, null);
                  }
                  if (r == 1) {
                    save();
                  }
                })));
  }
}
