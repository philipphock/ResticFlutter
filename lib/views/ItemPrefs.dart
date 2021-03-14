import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemPrefsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Title"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
    );
  }
}

class ItemPrefsModel extends ChangeNotifier {
  ItemPrefsModel() : super() {}
}
