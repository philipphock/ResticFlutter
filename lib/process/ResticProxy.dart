import 'dart:convert';

import 'package:restic_ui/process/process.dart';
import 'package:restic_ui/process/resticjsons.dart';

class ResticProxy {
  static final ProcessExecutor _executor = ProcessExecutor();
  static Future<List<SnapshotFile>> getFiles(
      String repo, String snid, String wd, String pw) async {
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
  }

  static Future<List<Snapshot>> getSnapshots(
      String repo, String wd, String pw) async {
    var l = await _exec(["snapshots"], repo, wd, pw);
    var ret = <Snapshot>[];
    var snapshots = jsonDecode(l);
    snapshots.forEach((element) {
      var s = Snapshot.fromJSON(element);
      ret.add(s);
    });

    return ret;
  }

  static Future forget(String repo, String snid, String wd, String pw) async {
    await _exec(["forget", snid], repo, wd, pw);
  }

  static Future extract(String repo, String includeOnly, String snapshotId,
      String where, String wd, String pw) async {
    var incl = "";
    if (includeOnly != null) {
      incl = "--include \"$includeOnly\"";
    }
    await _exec(
        ["restore", snapshotId, incl, "--target", "\"$where\""], repo, wd, pw);
  }

  static Future initBackup(String repo, String wd, String pw) async {
    await _exec(["init"], repo, wd, pw);
  }

  static Future doBackup(String repo, int keep, String wd, String pw) async {
    await _exec(["backup"], repo, wd, pw);
    if (keep > 0) {
      await _exec(["forget", "--keep-last", "$keep"], repo, wd, pw);
    }
  }

  static Future<String> _exec(
      List<String> args, String repo, String wd, String pw) async {
    var env = {"RESTIC_PASSWORD": pw, "RESTIC_REPOSITORY": repo};

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

main(List<String> args) async {
  var ss = await ResticProxy.getFiles(r"c:\test\repo", "latest", ".", "a");
  ss.forEach(print);
}
