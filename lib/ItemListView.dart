import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_world/comm.dart';

class ItemListView extends StatefulWidget {
  ItemListView({Key key, this.title}) : super(key: key);
  final String title;

  @override
  ItemListViewState createState() => ItemListViewState();
}

class ItemListViewState extends State<ItemListView> {
  final List<MyListItem> entries = [];
  ItemListViewState() : super() {
    $.itemRemoved.stream.listen((MyListItem i) {
      setState(() {
        entries.remove(i);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Title")),
      body: entries.length > 0
          ? ListView.builder(
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                final item = entries[index];
                return item;
              },
            )
          : Center(child: const Text('Use + to add an Item')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            entries.add(MyListItem(heading: "Item ${entries.length}"));
          });
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyListItem extends StatefulWidget {
  final String heading;

  MyListItem({Key key, this.heading}) : super(key: key);

  @override
  MyListItemState createState() => MyListItemState();
}

class MyListItemState extends State<MyListItem> {
  Color listItemColor = Colors.transparent;

  MyListItemState() {}

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onExit: (e) {
          setState(() {
            listItemColor = Colors.transparent;
          });
        },
        onHover: (e) {
          setState(() {
            listItemColor = Colors.lightBlue;
          });
        },
        child: Padding(
            padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
            child: Container(
                color: listItemColor,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Container(
                        child: Text(this.widget.heading),
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
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                $.itemRemoved.add(this.widget);
                              }),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                $.itemRemoved.add(this.widget);
                              }),
                        ],
                      )
                    ]))));
  }
}
