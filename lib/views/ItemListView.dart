import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/comm.dart';
import 'package:hello_world/main.dart';
import 'package:hello_world/views/ItemPrefs.dart';
import 'package:provider/provider.dart';

class ItemListView extends StatelessWidget {
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
                return MyListItem.elements(context, item);
              },
            )
          : Center(child: const Text('Use + to add an Item')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          listModel.AddItem();
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
  String heading;

  ListItemModel(this.heading);

  Color get listItemColor => _col;
  set listItemColor(Color value) {
    _col = value;
    notifyListeners();
  }
}

class ItemListModel extends ChangeNotifier {
  final List<ListItemModel> entries = [];
  ItemListModel() {
    $.itemRemoved.stream.listen((ListItemModel i) {
      entries.remove(i);
      notifyListeners();
    });
  }

  void AddItem() {
    this.entries.add(ListItemModel("Item ${entries.length}"));
    notifyListeners();
  }
}

class MyListItem {
  static Widget elements(BuildContext context, ListItemModel model) {
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
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, ItemPrefsView.ROUTE,
                                    arguments: model);
                              }),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                $.itemRemoved.add(model);
                              }),
                        ],
                      )
                    ]))));
  }
}
