import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    notifyListeners();
  }

  ListItemModel.clone(ListItemModel toClone) {
    this.from(toClone);
  }

  ListItemModel.fromJson(Map<String, dynamic> json)
      : this._heading = json['name'],
        this.dbId = json['_key'],
        this._keepSnaps = json['keepSnaps'],
        this._password = json['password'],
        this._repo = json['repo'],
        //this.source = jsonDecode(json['source']),
        this._lastBackup = json['lastBackup'];

  Map<String, dynamic> toJson() => {
        'name': this.heading,
        'keepSnaps': this.keepSnaps,
        'password': this.password,
        'repo': this.repo,
        'source': jsonEncode(this.source),
        'lastBackup': this._lastBackup
      };
}
