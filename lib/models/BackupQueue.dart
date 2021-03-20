import 'dart:async';

import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/widgets/MyListItem.dart';

class BackupQueue {
  static BackupQueue _singleton;

  factory BackupQueue.singleton() {
    if (_singleton == null) {
      _singleton = BackupQueue._internal();
    }
    return _singleton;
  }

  BackupQueue._internal();

  final jobs = <ListItemModel>[];
  final jobNotifier = StreamController<ListItemModel>.broadcast();

  void add(ListItemModel origin) {
    origin.state = JobStatus.ADDED;

    jobs.add(origin);

    checkAndRun();
  }

  void remove(ListItemModel m) {
    jobs.remove(m);

    m.state = JobStatus.NOT_IN_LIST;
  }

  ListItemModel getRunning() {
    return jobs.firstWhere((element) => element.state == JobStatus.RUNNING,
        orElse: () => null);
  }

  void checkAndRun() {
    for (var i in jobs) {
      if (i.state == JobStatus.RUNNING) {
        // a job is already running, nothing to do
        return;
      }
      if (i.state == JobStatus.ADDED) {
        //the order of jobs are in a way that the first 'ADDED' must be only one
        jobNotifier.add(i);

        i.runBackup();
        return;
      }
    }
  }
}
