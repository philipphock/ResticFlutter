import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class MyListItem extends StatefulWidget {
  final String heading;

  MyListItem(this.heading) : super();

  @override
  MyListItemState createState() => MyListItemState();
}

class $ {
  $._();
  static final StreamController<MyListItem> itemRemoved =
      StreamController<MyListItem>();
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
                      Text(this.widget.heading),
                      Row(
                        children: [
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

class _MyHomePageState extends State<MyHomePage> {
  final List<MyListItem> entries = [];
  _MyHomePageState() {
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
            entries.add(MyListItem("Item ${entries.length}"));
          });
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }
}
