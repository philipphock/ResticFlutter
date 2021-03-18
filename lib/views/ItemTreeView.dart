import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/ResticProxy.dart';
import 'package:restic_ui/process/resticjsons.dart';

class ItemTreeViewArgs {
  final ListItemModel model;
  final Snapshot snap;

  ItemTreeViewArgs(this.model, this.snap);
}

class ItemTreeView extends StatefulWidget {
  static const String ROUTE = "/tree";

  @override
  State<StatefulWidget> createState() => ItemTreeViewState();
}

class ItemTreeViewState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    ItemTreeViewArgs args = ModalRoute.of(context).settings.arguments;

    //print(item.heading);
    var fb = FutureBuilder<List<SnapshotFile>>(
      future: ResticProxy.getFiles(args.model.repo, args.snap.id, ".",
          args.model.password), //item.repo, "latest" item.password
      builder: (context, AsyncSnapshot<List<SnapshotFile>> data) {
        if (!data.hasData) {
          return Center(child: Expanded(child: CircularProgressIndicator()));
        } else {
          print(data.data);
          return TreeWidget(data.data);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tree"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
      body: fb,
    );
  }
}

class TreeWidget extends StatelessWidget {
  final List<SnapshotFile> items;
  TreeWidget(this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
        separatorBuilder: (context, index) =>
            Divider(color: Colors.black, height: 5),
        //shrinkWrap: true,
        //physics: ClampingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return items.length == 0
              ? Center(child: Text("no files"))
              : Container(child: Text(items[index].name));
        },
      ),
    );
  }
}
