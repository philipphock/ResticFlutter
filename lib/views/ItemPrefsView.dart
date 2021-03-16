import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/util/Filepicker.dart';

class ItemPrefsView extends StatelessWidget {
  static const String ROUTE = "/prefs";
  @override
  Widget build(BuildContext context) {
    final ListItemModel item = ModalRoute.of(context).settings.arguments;
    print(item.heading);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Inspect"),
          iconTheme: IconThemeData(
            color: Colors.white70, //change your color here
          ),
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                "Heading",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38),
              )),
          Padding(
              padding: EdgeInsets.all(1),
              child: Text(
                "Repo",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
              )),
          Padding(
              padding: EdgeInsets.all(1),
              child: Text(
                "Src",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28),
              )),

          // List
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.black, height: 5),
                      //shrinkWrap: true,
                      //physics: ClampingScrollPhysics(),
                      itemCount: 14,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            color: Colors.black38,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 30, horizontal: 5),
                                child: Row(children: [
                                  Text("Item"),
                                  Spacer(),
                                  IconButton(
                                      onPressed: () async {
                                        var f = await pickFolder(context);
                                        if (f != null) {}
                                      },
                                      icon: Icon(Icons.file_download)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.folder_open_rounded)),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ))
                                ])));
                      })))
        ]));
  }
}
