import 'dart:async';
import 'dart:io';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/ResticProxy.dart';
import 'package:restic_ui/util/Filepicker.dart';
import 'package:restic_ui/util/Log.dart';
import 'package:restic_ui/util/dialog.dart';

enum Operation { EDIT, NEW }

class ItemEditViewArgs {
  final Operation op;
  final ListItemModel model;
  ItemEditViewArgs(this.model, this.op);
  ItemEditViewArgs.edit(ListItemModel m) : this(m, Operation.EDIT);
  ItemEditViewArgs.create() : this(null, Operation.NEW);
}

class ItemEditView extends StatefulWidget with Log {
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
  ItemEditViewArgs args;
  bool processing = false;

  final dbag = DisposeBag();

  @override
  void dispose() {
    dbag.dispose();

    super.dispose();
  }

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
        log("pw = $_pw1");
      }
    });
  }

  void save() async {
    setState(() {
      processing = true;
    });
    if (args.op == Operation.NEW) {
      try {
        await ResticProxy.initBackup(ret.repo, ret.source[0], ret.password);
        Navigator.pop(context, ret);
      } catch (e) {
        setState(() {
          processing = false;
        });
        if (e.toString().contains("config file already exists")) {
          try {
            await ResticProxy.getSnapshots(ret.repo, ret.password);
            await showAlertDialog(
                context,
                "Info",
                "Repo existed before, password correct, operation successfull",
                DialogOption.ok());
            Navigator.pop(context, ret);
          } catch (e2) {
            await showAlertDialog(
                context, "Error", e2.toString(), DialogOption.ok());
          }
        }
      }
    } else {
      try {
        await ResticProxy.getSnapshots(ret.repo, ret.password);
        Navigator.pop(context, ret);
      } catch (e) {
        setState(() {
          processing = false;
        });
        showAlertDialog(
            context, "Error init repo", e.toString(), DialogOption.ok());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;

    if (args.op == Operation.NEW) {
      title = "New repo";
      edit = false;
      if (ret == null) {
        ret = ListItemModel();
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

    final TextEditingController repoController =
        TextEditingController(text: ret.repo ?? "");
    var l = () {
      ret.repo = repoController.text;
    };
    repoController.addListener(l);
    dbag.add(() => repoController.removeListener(l));

    final List<TextEditingController> srcController = <TextEditingController>[];

    ret.source?.asMap()?.forEach((index, element) {
      var c = TextEditingController(text: element ?? "");
      var l = () {
        ret.source[index] = c.text;
      };
      c.addListener(l);
      dbag.add(() => c.removeListener(l));
      srcController.add(c);
    });

    var scaf = Scaffold(
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
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: repoController,
                    decoration: InputDecoration(labelText: 'Repo'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.folder_open),
                  onPressed: () async {
                    var p = await pickFolder(context);
                    if (p != null) {
                      setState(() {
                        repoController.text = p.replaceAll(r"\", "/");
                      });
                    }
                  },
                ),
              ],
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
                    controller: srcController[index],
                    decoration: InputDecoration(labelText: 'Source path'),
                  )),
                  IconButton(
                      icon: Icon(Icons.folder_open),
                      onPressed: () async {
                        var p = await pickFolder(context);
                        if (p != null) {
                          setState(() {
                            srcController[index].text = p.replaceAll(r"\", "/");
                            //ret.source[index] = p;
                          });
                        }
                      }),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => setState(() {
                      ret.source.remove(ret.source[index]);
                      srcController.removeAt(index);
                    }),
                  )
                ]);
              },
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  ret.source.add("");
                });
              },
              icon: Icon(Icons.add),
            ),
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
                  ),
                ),
                IconButton(
                  icon: Icon(_pwVis ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(
                      () {
                        _pwVis = !_pwVis;
                      },
                    );
                  },
                )
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
                      initialValue: "${ret?.keepSnaps}",
                      keyboardType: TextInputType.number,
                      onChanged: (value) => ret.keepSnaps = int.parse(value),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
            var r = await showAlertDialog(
              context,
              "Warning",
              "Leave without saving?",
              [
                DialogOption<int>("yes, discard", 0),
                DialogOption<int>("no, save item", 1)
              ],
            );
            if (r == 0) {
              Navigator.pop(context, null);
            }
            if (r == 1) {
              save();
            }
          },
        ),
      ),
    );
    if (processing) {
      return Expanded(
          child: Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ));
    }
    return scaf;
  }
}
