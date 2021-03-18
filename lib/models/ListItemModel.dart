import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_ui/db/ListItemModelDao.dart';

class ListItemModel extends ChangeNotifier {
  int dbId = -1;
  Color _col = Colors.transparent;
  Color get listItemColor => _col;
  set listItemColor(Color value) {
    _col = value;
    notifyListeners();
  }

  ListItemModel();

  List<String> source = [];

  String _heading = "";
  int _lastBackup = 0;

  //String get lastBackup  =>

  String get lastBackupString {
    if (_lastBackup == 0) return "Never";
    var date = DateTime.fromMicrosecondsSinceEpoch(_lastBackup, isUtc: true);
    var format = DateFormat('dd.mm.yyyy HH:mm:ss').format(date);

    return format;
  }

  set heading(String value) {
    _heading = value;
    notifyListeners();
  }

  String get heading => _heading ?? "";

  String _repo = "";
  set repo(String value) {
    _repo = value;
    notifyListeners();
  }

  String get repo => _repo ?? "";

  String _password = "";
  set password(String value) {
    _password = value;
    notifyListeners();
  }

  String get password => _password ?? "";

  int _keepSnaps = 3;

  get keepSnaps => _keepSnaps;

  set keepSnaps(int value) {
    _keepSnaps = value;
    notifyListeners();
  }

  bool _savePw = true;

  get savePw => _savePw;

  set savePw(bool value) {
    _savePw = value;
    notifyListeners();
  }

  void from(ListItemModel m) {
    this.heading = m.heading;
    this.repo = m.repo;
    this.savePw = m.savePw;
    this.keepSnaps = m.keepSnaps;
    this.source = List.from(m.source);
    this.password = m.password;
    this._lastBackup = m._lastBackup;
    this.dbId = m.dbId;

    notifyListeners();
  }

  ListItemModel.clone(ListItemModel toClone) {
    this.from(toClone);
  }

  ListItemModel.fromJson(Map<String, dynamic> json) {
    this._heading = json['name'];
    this.dbId = json['_key'];
    this._keepSnaps = json['keepSnaps'];
    this._password = json['password'];
    this._repo = json['repo'];
    this._lastBackup = json['lastBackup'];
    this._savePw = json['savePW'];

    jsonDecode(
      json['source'],
      reviver: (key, value) {
        if (key != null) {
          this.source.add(value.toString());
        }
        return null;
      },
    );

    //this.source = decoded;
    //.map((key, value) => {key, value.toString()});
  }

  Map<String, dynamic> toJson() => {
        'name': this.heading,
        'keepSnaps': this.keepSnaps,
        'password': this.password,
        'repo': this.repo,
        'source': jsonEncode(this.source),
        'lastBackup': this._lastBackup,
        'savePW': this._savePw,
        'dbId': this.dbId
      };
}
