import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogOption<R> {
  final String label;
  final R returnValue;
  DialogOption(this.label, this.returnValue);

  static List<DialogOption> ok() {
    return [DialogOption<int>("ok", 0)];
  }
}

Future showAlertDialog<R>(BuildContext context, String title, String msg,
    List<DialogOption> options) {
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

AlertDialog showWaitDialog(BuildContext context, String title) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: SizedBox(
      width: 300,
      height: 300,
      child: Align(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    ),
  );

  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });

  return alert;
}

Future showInputDialog<R>(BuildContext context, String title, final String msg,
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
