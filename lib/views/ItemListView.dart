import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:restic_ui/db/ListItemModelDao.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/views/ItemEditView.dart';
import 'package:restic_ui/util/dialog.dart';
import 'package:provider/provider.dart';
import 'package:restic_ui/widgets/MyListItem.dart';

class ItemListView extends StatefulWidget {
  static const String ROUTE = "/";

  @override
  _ItemListViewState createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  @override
  Widget build(BuildContext context) {
    final listModel = context.watch<
        ItemListModel>(); // equivalent to Provider.of<ItemListModel>(context);
    final list = ListView.separated(
      separatorBuilder: (context, id) => Divider(
        height: 2,
        color: Colors.black,
      ),
      itemCount: listModel.entries.length + 2,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0 || index == listModel.entries.length + 1) {
          return Container(); // spacer at top and bottom
        }
        final item = listModel.entries[index - 1];
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: MyListItem(item, listModel));
      },
    );

    final emptyInfo = Center(
      child: const Text('Use + to add an Item'),
    );

    final addbutton = FloatingActionButton(
      onPressed: () {
        (() async {
          var i = await Navigator.pushNamed(context, ItemEditView.ROUTE,
              arguments: ItemEditViewArgs.create()) as ListItemModel;
          if (i != null) {
            setState(() {
              listModel.addItem(i);
            });
          }
        })();
      },
      tooltip: 'Add Item',
      child: Icon(Icons.add),
    );

    var ret = Scaffold(
      appBar: AppBar(title: const Text("Restic Backup UI")),
      body: listModel.entries.length > 0 ? list : emptyInfo,
      floatingActionButton: addbutton,
    );
    //ChangeNotifierProvider provider = ChangeNotifierProvider(
    //    create: (context) => ItemListModel(), child: ret);
    return ret;
  }
}

class ItemListModel extends ChangeNotifier {
  final subscriptions = <StreamSubscription>[];
  List<ListItemModel> entries = [];

  @override
  void dispose() {
    subscriptions.forEach((element) {
      element.cancel();
    });

    super.dispose();
  }

  void removeItem(BuildContext context, ListItemModel model) async {
    int choice = await showAlertDialog(
      context,
      "Delete?",
      "Delete this element?",
      [
        DialogOption<int>("no", 0),
        DialogOption<int>("yes, from list", 1),
        DialogOption<int>("yes, delete from file system", 2)
      ],
    );

    if (choice == 1) {
      entries.remove(model);
      ListItemModelDao.deleteItem(model);
      notifyListeners();
    }
    if (choice == 2) {
      try {
        new Directory(model.repo).delete(recursive: true);
        entries.remove(model);
        ListItemModelDao.deleteItem(model);
        notifyListeners();
      } catch (e) {
        showAlertDialog(context, "Error", e.toString(), DialogOption.ok());
      }
    }
  }

  ItemListModel() {
    (() async {
      entries = await ListItemModelDao.loadAllItems();
      notifyListeners();
    })();
  }

  void addItem(ListItemModel m) {
    this.entries.add(m);
    ListItemModelDao.createItem(m);

    notifyListeners();
    m.state = JobStatus.NOT_IN_LIST;
  }
}
