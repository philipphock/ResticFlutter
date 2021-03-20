import 'dart:async';

import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/ResticProxy.dart';

enum JobStatus { ADDED, RUNNING, DONE_SUCCESS, DONE_ERROR, NOT_IN_LIST }

class Job {
  final ListItemModel origin;
  String errorMsg;
  Future proc;
  JobStatus stat = JobStatus.NOT_IN_LIST;

  Job(this.origin);

  void run() async {
    stat = JobStatus.RUNNING;
    BackupQueue.singleton().jobStatus.add(this);
    try {
      this.proc = await ResticProxy.doBackup(
          origin.repo, origin.keepSnaps, origin.source[0], origin.password);
      stat = JobStatus.DONE_SUCCESS;
    } catch (e) {
      errorMsg = e;
      stat = JobStatus.DONE_ERROR;
    }
    BackupQueue.singleton().jobStatus.add(this);
  }
}

class BackupQueue {
  static BackupQueue _singleton;
  StreamController<Job> jobStatus = StreamController.broadcast();

  factory BackupQueue.singleton() {
    if (_singleton == null) {
      _singleton = BackupQueue._internal();
      _singleton.jobStatus.stream.listen((event) {
        if (event.stat == JobStatus.DONE_SUCCESS ||
            event.stat == JobStatus.DONE_ERROR) {}
      });
    }
    return _singleton;
  }

  BackupQueue._internal();

  final List<Job> jobs = <Job>[];

  void add(ListItemModel origin) {
    var j = Job(origin);
    j.stat = JobStatus.ADDED;
    jobs.add(j);
    checkAndRun();
  }

  void remove(ListItemModel m) {
    var j = getJob(m);
    if (j != null) {
      jobs.remove(j);
      j.stat = JobStatus.NOT_IN_LIST;
      jobStatus.add(j);
    }
  }

  void checkAndRun() {
    for (var i in jobs) {
      if (i.stat == JobStatus.ADDED) {
        //the order of jobs are in a way that the first 'ADDED' must be only one
        i.run();
        return;
      }
    }
  }

  Job getJob(ListItemModel m) {
    return jobs.firstWhere((element) => element.origin == m,
        orElse: () => null);
  }

  Job getRunning() {
    return jobs.firstWhere((element) => element.stat == JobStatus.RUNNING,
        orElse: () => null);
  }

  void dispose() {
    jobStatus.close();
  }
}
