import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorLogView extends StatelessWidget {
  static const String ROUTE = "/err";
  const ErrorLogView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String errorLog = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Error log"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Text(errorLog),
      ),
    );
  }
}
