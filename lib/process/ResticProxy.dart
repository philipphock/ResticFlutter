import 'dart:convert';

import 'package:restic_ui/process/process.dart';
import 'package:restic_ui/process/resticjsons.dart';

class ResticProxy {
  static final ProcessExecutor _executor = ProcessExecutor();
  static Future<List<SnapshotFile>> getFiles(
      String repo, String snid, String wd, String pw) async {
    try {
      var l = await _exec(["ls", snid], repo, wd, pw);
      var splitter = LineSplitter();
      var lines = splitter.convert(l);

      var ret = <SnapshotFile>[];

      lines.forEach((line) {
        var file = jsonDecode(line);
        if (file['struct_type'] == 'node') {
          var f = SnapshotFile.fromJSON(file);
          ret.add(f);
        }
      });
      return ret;
    } catch (e) {
      throw e;
    }
  }

  static Future<List<Snapshot>> getSnapshots(String repo, String pw) async {
    try {
      var l = await _exec(["snapshots"], ".", repo, pw);
      var ret = <Snapshot>[];
      var snapshots = jsonDecode(l);
      snapshots.forEach((element) {
        var s = Snapshot.fromJSON(element);
        ret.add(s);
      });

      return ret;
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future forget(String repo, String snid, String wd, String pw) async {
    return _exec(["forget", snid], repo, wd, pw);
  }

  static Future extract(String repo, String includeOnly, String snapshotId,
      String where, String wd, String pw) async {
    var incl = <String>[];
    if (includeOnly != null) {
      incl = ["--include", includeOnly];
    }
    return _exec(
        ["restore", snapshotId] + incl + ["--target", where], repo, wd, pw);
  }

  static Future initBackup(String repo, String wd, String pw) async {
    return _exec(["init"], repo, wd, pw);
  }

  static Future doBackup(String repo, int keep, String wd, String pw) async {
    try {
      await _exec(["backup"], repo, wd, pw);
    } catch (e) {
      throw e;
    }
    if (keep > 0) {
      return _exec(["forget", "--keep-last", "$keep"], repo, wd, pw);
    }
  }

  static Future<String> _exec(
      List<String> args, String repo, String wd, String pw) async {
    var env = {"RESTIC_PASSWORD": pw, "RESTIC_REPOSITORY": repo};
    var sum;
    try {
      var p = await _executor.exec(args + ["--json"], wd, env);
      sum = await p.summary();
    } catch (e) {
      throw e;
    }

    if (sum.errStartInfo != "") {
      throw Exception("Error executing proxy: ${sum.errStartInfo}");
    }

    if (sum.exitCode != 0) {
      throw Exception(sum.stderr);
    }
    return sum.stdout;
  }
}

main(List<String> args) async {
  try {
    await ResticProxy.initBackup(r"c:\test\repo", ".", "a");
  } catch (e) {
    print(e);
  }
}
