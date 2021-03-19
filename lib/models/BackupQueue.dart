import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/process.dart';

class Job {
  final ListItemModel origin;
  final ProcessInfo proc;

  Job(this.origin, this.proc);
}

class BackupQueue {
  static BackupQueue _singleton;

  factory BackupQueue() {
    if (_singleton == null) {
      _singleton = BackupQueue._internal();
    }
    return _singleton;
  }

  BackupQueue._internal();

  final List<Job> jobs = <Job>[];

  void add(ListItemModel origin) {}
}
