import 'package:flutter/material.dart';
import 'package:restic_ui/comm.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/views/ItemEditView.dart';
import 'package:restic_ui/views/ItemListView.dart';
import 'package:restic_ui/views/ItemPrefsView.dart';

class MyListItem extends StatelessWidget {
  final ListItemModel model;
  final ItemListModel parent;
  MyListItem(this.model, this.parent);

  @override
  Widget build(BuildContext context) {
    var name = Flexible(
        child: Container(
      child: Text(model?.heading ?? ""),
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
                Text("TODO", textAlign: TextAlign.left)
              ],
            ),
            Row(
              children: [
                Text("Repo: "),
                Text(model.repo, textAlign: TextAlign.left)
              ],
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Source: "),
              Text(model.source.join("\n"), textAlign: TextAlign.left)
            ]),
          ],
        ),
      ),
    );

    var buttons = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.playlist_add),
          onPressed: () {
            $.itemEnqueuButton.emit(ContextPayload(context, model));
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            Navigator.pushNamed(context, ItemPrefsView.ROUTE, arguments: model);
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            var a = await Navigator.pushNamed(context, ItemEditView.ROUTE,
                arguments: ItemEditViewArgs.edit(model));
            if (a != null) {
              model.from(a);
              parent.notifyListeners();
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            $.itemRemove.emit(
              ContextPayload(context, model),
            );
          },
        ),
      ],
    );

    return MouseRegion(
      onExit: (e) {
        model.listItemColor = Colors.transparent;
      },
      onHover: (e) {
        model.listItemColor = Colors.lightBlue;
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
        child: Container(
          color: model.listItemColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [name, paths, buttons],
          ),
        ),
      ),
    );
  }
}
