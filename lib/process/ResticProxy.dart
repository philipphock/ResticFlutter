import 'dart:convert';

import 'package:restic_ui/process/process.dart';
import 'package:restic_ui/process/resticjsons.dart';

class ResticProxy {
  static final ProcessExecutor _executor = ProcessExecutor();
  static Future<List<Snapshot>> getSnapshots(String repo, String wd) async {
    var l = await _exec("snapshots", repo, wd);
    //var splitter = LineSplitter();
    //var lines = splitter.convert(l);
    var ret = <Snapshot>[];
    var snapshots = jsonDecode(l);
    snapshots.forEach((element) {
      var s = Snapshot.fromJSON(element);
      ret.add(s);
    });

    //lines.forEach((line) {
    //
    //});
    return ret;
  }

  static Future forget(String repo, String snid, String wd, String pw) async {
    await _exec(["forget", snid], repo, wd, pw);
  }

  static Future extract(String repo, String includeOnly, String snapshotId,
      String wd, String pw) async {
    var incl = "";
    if (includeOnly != null) {
      incl = "--include \"$includeOnly\"";
    }
    await _exec(["extract", snapshotId, incl], repo, wd, pw);
  }

  static Future initBackup(String repo, String wd, String pw) async {
    await _exec(["init"], repo, wd, pw);
  }

  static Future doBackup(String repo, String wd, String pw) async {
    await _exec(["backup"], repo, wd, pw);
  }

  static Future<String> _exec(
      List<String> args, String repo, String wd, String pw) async {
    var env = {"RESTIC_PASSWORD": "a", "RESTIC_REPOSITORY": repo};

    var p = await _executor.exec(args + ["--json"], wd, env);
    var sum = await p.summary();
    if (sum.errStartInfo != "") {
      throw Exception("Error executing proxy: ${sum.errStartInfo}");
    }
    if (sum.exitCode != 0) {
      throw Exception(sum.stderr);
    }
    return sum.stdout;
  }
}
