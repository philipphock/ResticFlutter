import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/comm.dart';
import 'package:hello_world/views/ItemEditView.dart';
import 'package:hello_world/views/ItemPrefsView.dart';
import 'package:hello_world/views/dialog.dart';
import 'package:provider/provider.dart';

class ItemListView extends StatelessWidget {
  static const String ROUTE = "/";

  ItemListView() {
    $.itemEdit.stream.listen((e) {
      Navigator.pushNamed(e.context, ItemEditView.ROUTE, arguments: e.payload);
    });
    $.itemEnqueuButton.stream.listen((e) {
      //Navigator.pushNamed(e.context, ItemPrefsView.ROUTE, arguments: e.payload);
    });

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
                return MyListItem(item);
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

class ListItemModel extends ChangeNotifier {
  Color _col = Colors.transparent;
  String heading = "";
  List<TextEditingController> source = [];

  ListItemModel({this.heading});

  Color get listItemColor => _col;
  set listItemColor(Color value) {
    _col = value;
    notifyListeners();
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
  MyListItem(this.model);

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
                              onPressed: () {
                                $.itemEdit.emit(ContextPayload(context, model));
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
