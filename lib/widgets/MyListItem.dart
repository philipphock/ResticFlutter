import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restic_ui/comm.dart';
import 'package:restic_ui/db/ListItemModelDao.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/views/ItemEditView.dart';
import 'package:restic_ui/views/ItemListView.dart';
import 'package:restic_ui/views/ItemPrefsView.dart';

enum JobStatus { ADDED, RUNNING, DONE_SUCCESS, DONE_ERROR, NOT_IN_LIST }

class MyListItem extends StatefulWidget {
  final ListItemModel model;
  final ItemListModel parent;

  MyListItem(this.model, this.parent);

  @override
  _MyListItemState createState() => _MyListItemState(this.model, this.parent);
}

class _MyListItemState extends State<MyListItem> {
  final ListItemModel model;
  final ItemListModel parent;
  StreamSubscription subscription;
  _MyListItemState(this.model, this.parent) {
    subscription = model.changeListener.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var name = Flexible(
        child: Container(
      child: Text(widget.model.heading),
      width: 200,
      alignment: Alignment.centerLeft,
    ));

    var paths = Flexible(
      child: Container(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Last Backup: "),
                Text(widget.model.lastBackupString, textAlign: TextAlign.left)
              ],
            ),
            Row(
              children: [
                Text("Repo: "),
                Text(widget.model.repo, textAlign: TextAlign.left)
              ],
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Source: "),
              Text(widget.model.source.join("\n"), textAlign: TextAlign.left)
            ]),
          ],
        ),
      ),
    );

    var buttons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: Icon(this.widget.model.qIcon),
          onPressed: () {
            this.model.enqueueButtonClick(context);
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.pushNamed(context, ItemPrefsView.ROUTE,
                arguments: widget.model);
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            var a = await Navigator.pushNamed(context, ItemEditView.ROUTE,
                arguments: ItemEditViewArgs.edit(widget.model));
            if (a != null) {
              widget.model.from(a);
              ListItemModelDao.updateItem(widget.model);
              widget.parent.notifyListeners();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            $.itemRemove.add(
              ContextPayload(context, widget.model),
            );
          },
        ),
      ],
    );

    return MouseRegion(
      onExit: (e) {
        widget.model.listItemColor = Colors.transparent;
      },
      onHover: (e) {
        widget.model.listItemColor = Colors.lightBlue;
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
        child: Container(
          color: widget.model.listItemColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [name, paths, buttons],
          ),
        ),
      ),
    );
  }
}
