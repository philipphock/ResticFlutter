import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restic_ui/comm.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/views/ItemEditView.dart';
import 'package:restic_ui/util/dialog.dart';
import 'package:provider/provider.dart';
import 'package:restic_ui/widgets/MyListItem.dart';

class ItemListView extends StatelessWidget {
  static const String ROUTE = "/";

  @override
  Widget build(BuildContext context) {
    var listModel = context.watch<ItemListModel>();

    var ret = Scaffold(
      appBar: AppBar(title: const Text("Title")),
      body: listModel.entries.length > 0
          ? ListView.separated(
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
            )
          : Center(
              child: const Text('Use + to add an Item'),
            ),
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
    $.itemRemove.stream.listen(
      (i) async {
        int choice = await showAlertDialog(
          i.context,
          "Delete?",
          "Delete this element?",
          [
            DialogOption<int>("no", 0),
            DialogOption<int>("yes, from list", 1),
            DialogOption<int>("yes, delete from file system", 2)
          ],
        );

        if (choice == 1) {
          entries.remove(i.payload);
          notifyListeners();
        }
      },
    );
  }

  void AddItem(ListItemModel m) {
    this.entries.add(m);
    notifyListeners();
  }
}
