class BackupQueue {
  static BackupQueue _singleton;

  factory BackupQueue() {
    if (_singleton == null) {
      _singleton = BackupQueue._internal();
    }
    return _singleton;
  }

  BackupQueue._internal();
}
