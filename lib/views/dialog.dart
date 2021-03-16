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

  static Future showInputDialog<R>(
      BuildContext context, String title, final String msg,
      {int len = 1000}) {
    // set up the buttons
    Completer<String> ret = Completer();
    String inputText = "";
    var ok = TextButton(
        child: Text("OK"),
        onPressed: () {
          Navigator.of(context).pop();
          ret.complete(inputText);
        });
    var cancel = TextButton(
        child: Text("cancel"),
        onPressed: () {
          Navigator.of(context).pop();
          ret.complete(null);
        });

    var input = TextField(
        autofocus: true,
        maxLength: len,
        autocorrect: false,
        onSubmitted: (value) {
          Navigator.of(context).pop();
          ret.complete(inputText);
        },
        decoration: InputDecoration(hintText: msg),
        onChanged: (value) {
          inputText = value;
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: input,
      actions: [ok, cancel],
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
