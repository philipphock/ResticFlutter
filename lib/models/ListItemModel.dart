import 'dart:convert';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_ui/models/BackupQueue.dart';

class ListItemModel extends ChangeNotifier {
  int dbId = -1;
  Color _col = Colors.transparent;
  Color get listItemColor => _col;
  BackupQueue q;
  final DisposeBag dbag = DisposeBag();

  set listItemColor(Color value) {
    _col = value;
    notifyListeners();
  }

  IconData qIcon = Icons.device_unknown;
  /*
  const Icon(Icons
              .play_arrow_sharp), //Icons.check (done), Icons.error(fail) Icons.stop (running), play_arrow_sharp (play no queue), queue_sharp (play in queue)
  */

  void init() {
    q = BackupQueue.singleton();
    dbag.add(q.jobStatus.stream.listen((event) {
      if (event.origin == this) {
        switch (event.stat) {
          case JobStatus.ADDED:
            qIcon = Icons.cancel_outlined;
            break;
          case JobStatus.RUNNING:
            qIcon = Icons.stop;
            break;
          case JobStatus.DONE_SUCCESS:
            qIcon = Icons.remove_circle_outline;
            break;
          case JobStatus.DONE_ERROR:
            qIcon = Icons.error;
            break;
          case JobStatus.NOT_IN_LIST:
            if (q.getRunning() == null) {
              qIcon = Icons.play_arrow_outlined;
            } else {
              qIcon = Icons.queue_sharp;
            }
            break;
        }
      } else {
        if (q.getRunning() == null) {
          qIcon = Icons.play_arrow_outlined;
        } else {
          qIcon = Icons.queue_sharp;
        }
      }
      notifyListeners();
    }));
    //var j = q.getJob(this);
    if (q.getRunning() == null) {
      qIcon = Icons.play_arrow_outlined;
    } else {
      qIcon = Icons.queue_sharp;
    }
    notifyListeners();
  }

  ListItemModel() {}

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

  void enqueueButtonClick() {
    q.getJob(this)?.stat;
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
    init();
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

  @override
  void dispose() {
    dbag.dispose();
    super.dispose();
  }
}
