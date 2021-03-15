import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restic_ui/comm.dart';
import 'package:restic_ui/models/ItemListModel.dart';
import 'package:restic_ui/views/ItemEditView.dart';
import 'package:restic_ui/views/ItemPrefsView.dart';
import 'package:restic_ui/views/dialog.dart';
import 'package:provider/provider.dart';

class ItemListView extends StatelessWidget {
  static const String ROUTE = "/";

  ItemListView() {
    $.itemInspect.stream.listen((e) {
      Navigator.pushNamed(e.context, ItemPrefsView.ROUTE, arguments: e.payload);
    });
  }

  @override
  Widget build(BuildContext context) {
    var listModel = context.watch<ItemListModel>();

    var ret = Scaffold(
      appBar: AppBar(title: const Text("Title")),
      body: listModel.entries.length > 0
          ? ListView.builder(
              itemCount: listModel.entries.length,
              itemBuilder: (BuildContext context, int index) {
                final item = listModel.entries[index];
                return MyListItem(item, listModel);
              },
            )
          : Center(child: const Text('Use + to add an Item')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var i = await Navigator.pushNamed(context, ItemEditView.ROUTE,
              arguments: ItemEditViewArgs.create()) as ListItemModel;
          if (i != null) {
            print("pushed");
            listModel.AddItem(i);
          }
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
    //ChangeNotifierProvider provider = ChangeNotifierProvider(
    //    create: (context) => ItemListModel(), child: ret);
    return ret;
  }
}

class ItemListModel extends ChangeNotifier {
  final List<ListItemModel> entries = [];
  ItemListModel() {
    $.itemRemove.stream.listen((i) async {
      int choice = await MyDialog.showAlertDialog(
          i.context, "Delete?", "Delete this element?", [
        DialogOption<int>("no", 0),
        DialogOption<int>("yes, from list", 1),
        DialogOption<int>("yes, delete from file system", 2)
      ]);

      if (choice == 1) {
        entries.remove(i.payload);
        notifyListeners();
      }
    });
  }

  void AddItem(ListItemModel m) {
    this.entries.add(m);
    notifyListeners();
  }
}

class MyListItem extends StatelessWidget {
  final ListItemModel model;
  final ItemListModel parent;
  MyListItem(this.model, this.parent);

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      Flexible(
                          child: Container(
                        child: Text(model.heading),
                        width: 200,
                        alignment: Alignment.centerLeft,
                      )),
                      Flexible(
                          child: Container(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "asd",
                                  ),
                                  Text("asdsa", textAlign: TextAlign.left),
                                  Text("asas", textAlign: TextAlign.left)
                                ],
                              ))),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.playlist_add),
                              onPressed: () {
                                $.itemEnqueuButton
                                    .emit(ContextPayload(context, model));
                              }),
                          IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                $.itemInspect
                                    .emit(ContextPayload(context, model));
                              }),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                var a = await Navigator.pushNamed(
                                    context, ItemEditView.ROUTE,
                                    arguments: ItemEditViewArgs.edit(model));
                                if (a != null) {
                                  model.from(a);
                                  print("EDITED");
                                  parent.notifyListeners();
                                }
                              }),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                $.itemRemove
                                    .emit(ContextPayload(context, model));
                              }),
                        ],
                      )
                    ]))));
  }
}
