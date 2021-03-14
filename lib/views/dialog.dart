import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogOption<R> {
  final String label;
  final R returnValue;
  DialogOption(this.label, this.returnValue);
}

class MyDialog {
  static Future showAlertDialog<R>(BuildContext context, String title,
      String msg, List<DialogOption> options) {
    // set up the buttons
    Completer<R> ret = Completer();
    var buttons = <Widget>[];

    options.forEach((element) {
      var e = TextButton(
          child: Text(element.label),
          onPressed: () {
            Navigator.of(context).pop();
            ret.complete(element.returnValue);
          });
      buttons.add(e);
    });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: buttons,
    );

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });

    return ret.future;
  }
}
