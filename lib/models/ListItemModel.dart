import 'dart:convert';

import 'package:disposebag/disposebag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restic_ui/db/ListItemModelDao.dart';
import 'package:restic_ui/models/BackupQueue.dart';
import 'package:restic_ui/process/ResticProxy.dart';
import 'package:restic_ui/util/ModelNotifyer.dart';
import 'package:restic_ui/views/ErrorLogView.dart';
import 'package:restic_ui/views/ItemListView.dart';
import 'package:restic_ui/widgets/MyListItem.dart';

class ListItemModel with ModelNotifier {
  int dbId = -1;
  Color _col = Colors.transparent;
  Color get listItemColor => _col;
  BackupQueue q = BackupQueue.singleton();
  JobStatus _state = JobStatus.NOT_IN_LIST;
  String lastErrorMsg;

  final DisposeBag dbag = DisposeBag();

  set listItemColor(Color value) {
    _col = value;
    notifyListeners();
  }

  JobStatus get state => _state;
  IconData qIcon = Icons.device_unknown;

  set state(JobStatus s) {
    switch (s) {
      case JobStatus.ADDED:
        qIcon = Icons.remove_circle;
        break;
      case JobStatus.RUNNING:
        qIcon = Icons.run_circle_rounded;
        break;
      case JobStatus.DONE_SUCCESS:
        qIcon = Icons.check_box;
        break;
      case JobStatus.DONE_ERROR:
        qIcon = Icons.error;
        break;
      case JobStatus.NOT_IN_LIST:
        if (q.getRunning() != null) {
          qIcon = Icons.playlist_add;
        } else {
          qIcon = Icons.play_arrow_outlined;
        }

        break;
    }
    this._state = s;
    notifyListeners();
  }

  ListItemModel();

  List<String> source = [];

  String _heading = "";
  int _lastBackup = 0;

  //String get lastBackup  =>

  String get lastBackupString {
    if (_lastBackup == 0) return "Never";
    var date = DateTime.fromMillisecondsSinceEpoch(_lastBackup);

    var format = DateFormat('dd.MM.yyyy HH:mm:ss').format(date);

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

  void enqueueButtonClick(BuildContext context) {
    if (state == JobStatus.DONE_ERROR) {
      Navigator.pushNamed(context, ErrorLogView.ROUTE, arguments: lastErrorMsg);
    } else if (state == JobStatus.NOT_IN_LIST) {
      q.add(this);
    } else if (state == JobStatus.ADDED || state == JobStatus.DONE_SUCCESS) {
      q.remove(this);
    } else if (state == JobStatus.RUNNING) {
      // TODO kill process
    }
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

  void init() {
    print("init");
    dbag.add(q.jobNotifier.stream.listen((event) {
      state = state;
      print("state change");
      notifyListeners();
    }));
  }

  ListItemModel.clone(ListItemModel toClone) {
    this.from(toClone);
  }

  void runBackup() async {
    print("job");

    this.state = JobStatus.RUNNING;

    try {
      // TODO get process to kill;
      await ResticProxy.doBackup(repo, source, keepSnaps, source[0], password);

      this.state = JobStatus.DONE_SUCCESS;
      _lastBackup = DateTime.now().millisecondsSinceEpoch;
      print(_lastBackup);
      ListItemModelDao.updateItem(this);
      q.checkAndRun();
    } catch (e) {
      lastErrorMsg = e;
      this.state = JobStatus.DONE_ERROR;
      q.checkAndRun();
    }
    notifyListeners();
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
    this.state = JobStatus.NOT_IN_LIST;
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
