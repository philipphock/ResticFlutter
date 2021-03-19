import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restic_ui/comm.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/ResticProxy.dart';
import 'package:restic_ui/process/resticjsons.dart';
import 'package:restic_ui/util/Filepicker.dart';
import 'package:restic_ui/util/dialog.dart';
import 'package:restic_ui/views/ItemTreeView.dart';

class ItemPrefsView extends StatefulWidget {
  static const String ROUTE = "/prefs";
  const ItemPrefsView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ItemPrefsViewState();
}

class ItemPrefsViewState extends State<ItemPrefsView> {
  @override
  Widget build(BuildContext context) {
    final ListItemModel item = ModalRoute.of(context).settings.arguments;
    $.snapshotRemoved.stream.listen((event) {
      setState(() {});
    });
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Inspect"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // top labels

          Padding(
            padding: EdgeInsets.all(5),
            child: Text(
              item.heading,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 38),
            ),
          ),
          Center(
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Repo:     ${item.repo}",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 28),
                    ),
                    Text(
                      "Source:  ${item.source.join('\n')}",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                )
              ],
            ),
          ),

          // /top labels

          // List
          FutureBuilder<List<Snapshot>>(
            future: ResticProxy.getSnapshots(item.repo, item.password),
            builder: (context, AsyncSnapshot<List<Snapshot>> data) {
              if (!data.hasData) {
                return Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator()));
              } else {
                return SnapshotList(data.data, item);
              }
            },
          ),
        ],
      ),
    );
    ;
  }
}

class SnapshotList extends StatelessWidget {
  final List<Snapshot> item;
  final ListItemModel model;
  SnapshotList(this.item, this.model);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.separated(
            separatorBuilder: (context, index) =>
                Divider(color: Colors.black, height: 5),
            //shrinkWrap: true,
            //physics: ClampingScrollPhysics(),
            itemCount: item.length,
            itemBuilder: (BuildContext context, int index) {
              return item.length == 0
                  ? Center(child: Text("no snapshots"))
                  : Container(
                      color: Colors.black38,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 30, horizontal: 5),

                        // Buttons

                        child: Row(children: [
                          Text(item[index].time),
                          Spacer(),
                          IconButton(
                              onPressed: () async {
                                var folder = await pickFolder(context);
                                if (folder != null) {
                                  showWaitDialog(context, "extracting...");
                                  await ResticProxy.extract(
                                      model.repo,
                                      null,
                                      item[index].id,
                                      folder,
                                      ".",
                                      model.password);
                                  Navigator.of(context).pop();

                                  //TODO show wait animation
                                  await showAlertDialog(
                                      context,
                                      "Extraction complete",
                                      "",
                                      DialogOption.ok());
                                }
                              },
                              icon: Icon(Icons.file_download)),
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, ItemTreeView.ROUTE,
                                  arguments:
                                      ItemTreeViewArgs(model, item[index]));
                            },
                            icon: Icon(Icons.folder_open_rounded),
                          ),
                          IconButton(
                            onPressed: () async {
                              var del = await showAlertDialog(context,
                                  "delete snapshot?", item[index].time, [
                                DialogOption("delete", 1),
                                DialogOption("cancel", 0)
                              ]);
                              if (del == 1) {
                                await ResticProxy.forget(model.repo,
                                    item[index].id, ".", model.password);
                                $.snapshotRemoved
                                    .add(ContextPayload(context, item[index]));
                              }
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          )
                        ]),

                        // Buttons
                      ),
                    );
            }),
      ),
    );
  }
}
