import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/util/Log.dart';
import 'package:restic_ui/views/dialog.dart';

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

class ItemEditState extends State<ItemEditView> with Log {
  String _title = "New repo";
  bool pwMatch = true;
  ListItemModel ret;
  bool edit = false;
  bool _pwVis = true;
  String _pw2;
  String _pw1;

  String get title => _title;
  set title(String value) {
    setState(() {
      _title = value;
    });
  }

  void validatePWs() {
    setState(() {
      pwMatch = _pw1 == _pw2;
      if (pwMatch) {
        ret.password = _pw1;
      }
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
      edit = false;
      if (ret == null) {
        ret = ListItemModel(heading: "");
        if (Platform.isWindows) {
          ret.source.add("c:/");
        } else {
          ret.source.add("/");
        }
      }
    } else {
      if (ret == null) {
        edit = true;
        title = "Edit repo";
        ret = ListItemModel.clone(args.model);
        _pw1 = ret.password;
        _pw2 = ret.password;
      }
    }

    return Scaffold(
        body: Padding(
            padding: EdgeInsets.all(10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextFormField(
                initialValue: ret.heading,
                onChanged: (s) {
                  ret.heading = s;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                initialValue: ret.repo,
                onChanged: (s) {
                  ret.repo = s;
                },
                decoration: InputDecoration(labelText: 'Repo'),
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
                      initialValue: ret.source[index],
                      onChanged: (s) {
                        ret.source[index] = s;
                      },
                      decoration: InputDecoration(labelText: 'Source path'),
                    )),
                    IconButton(
                        icon: Icon(Icons.folder_open),
                        onPressed: () => setState(() async {
                              var p = await FilesystemPicker.open(
                                  context: context,
                                  fsType: FilesystemType.folder,
                                  rootDirectory: Directory.fromUri(Uri.file(
                                      ret.source[index],
                                      windows: Platform.isWindows)));
                              if (p != null) {
                                ret.source[index] = p;
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
                      ret.source.add("");
                      print("ADDED ${ret.source.length}");
                    });
                  },
                  icon: Icon(Icons.add)),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    obscureText: _pwVis,
                    enableSuggestions: false,
                    autocorrect: false,
                    initialValue: ret.password,
                    onChanged: (s) {
                      _pw1 = s;
                      validatePWs();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  )),
                  IconButton(
                      icon: Icon(
                          _pwVis ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _pwVis = !_pwVis;
                        });
                      })
                ],
              ),
              TextFormField(
                obscureText: _pwVis,
                enableSuggestions: false,
                autocorrect: false,
                initialValue: ret.password,
                onChanged: (s) {
                  _pw2 = s;
                  validatePWs();
                },
                decoration: InputDecoration(labelText: 'Password'),
              ),
              Visibility(
                  visible: !pwMatch,
                  child: Text(
                    "passwords don't match",
                    style: TextStyle(color: Colors.red, fontSize: 11),
                  )),
              Row(
                children: [
                  Text("Snapshots to keep: "),
                  SizedBox(
                      width: 50,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        initialValue: "${ret.keepSnaps}",
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      )),
                  Flexible(child: Text("Save password")),
                  Flexible(
                      child: Checkbox(
                    value: ret.savePw,
                    onChanged: (v) {
                      setState(() {
                        ret.savePw = v;
                      });
                    },
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
