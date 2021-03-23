import 'dart:async';
import 'dart:convert';

import 'dart:io';

enum ProcessInfoEventType { STDERR, STDOUT, EXIT, ERR }

class ProcessInfoEventArgs {
  final String cmd;
  final ProcessInfoEventType type;
  final int exitCode;
  final String stderr;
  final String stdout;
  final String errStartInfo;

  ProcessInfoEventArgs(this.cmd, this.type, this.exitCode, this.stderr,
      this.stdout, this.errStartInfo);

  @override
  String toString() {
    var ret = """
    command: $cmd
    type: $type
    exitCode: $exitCode
    StdErr: $stderr
    StdOut: $stdout
    ErrStartInfo: $errStartInfo
    """;
    return ret;
  }
}

class ProcessSummary {
  final String stderr;
  final String stdout;
  final int exitCode;
  final String errStartInfo;

  ProcessSummary(this.stderr, this.stdout, this.exitCode, this.errStartInfo);

  @override
  String toString() {
    return """
    StartInfo: $errStartInfo
    ExitCode: $exitCode
    StdOut: $stdout
    StdErr: $stderr
    """;
  }
}

class ProcessInfo {
  final Process _p;
  final Stream<String> _stdout;
  final Stream<String> _stderr;
  final StreamController<ProcessInfoEventArgs> _event;
  final String _cmd;

  ProcessInfo(this._p, this._cmd)
      : _stderr = _p.stderr.transform(utf8.decoder), //.forEach(print);
        _stdout = _p.stdout.transform(utf8.decoder), //.forEach(print);
        _event = StreamController() {
    (() async {
      try {
        _stderr.forEach((element) {
          if (!_event.isClosed) {
            _event.add(ProcessInfoEventArgs(
                _cmd, ProcessInfoEventType.STDERR, -1, element, "", ""));
          }
        });
        _stdout.forEach((element) {
          if (!_event.isClosed) {
            _event.add(ProcessInfoEventArgs(
                _cmd, ProcessInfoEventType.STDOUT, -1, "", element, ""));
          }
        });
        int exit = await _p.exitCode;

        _event.add(ProcessInfoEventArgs(
            _cmd, ProcessInfoEventType.EXIT, exit, "", "", ""));
        _event.close();
      } catch (e) {
        ProcessInfoEventArgs(
            _cmd, ProcessInfoEventType.EXIT, -1, "", "", e.toString());
        _event.close();
      }
    })();
  }

  Stream<ProcessInfoEventArgs> get stream => _event.stream;

  bool kill() {
    return _p.kill();
  }

  Future<int> get exitCode {
    return _p.exitCode;
  }

  Future<ProcessSummary> summary() async {
    final StringBuffer sberr = StringBuffer();
    final StringBuffer sbout = StringBuffer();

    Completer<ProcessSummary> _exec = Completer();
    final l = (event) {
      switch (event.type) {
        case ProcessInfoEventType.STDERR:
          sberr.write(event.stderr);
          break;
        case ProcessInfoEventType.STDOUT:
          sbout.write(event.stdout);
          break;
        case ProcessInfoEventType.EXIT:
          var c = ProcessSummary(
              sberr.toString(), sbout.toString(), event.exitCode, "");
          _exec.complete(c);

          break;
        case ProcessInfoEventType.ERR:
          var c = ProcessSummary(
              sberr.toString(), sbout.toString(), -1, event.errStartInfo);

          _exec.complete(c);

          break;
      }
    };

    var s = stream.listen(l);
    _exec.future.then((value) => s.cancel());
    return _exec.future;
  }
}

class ProcessExecutor {
  Future<ProcessInfo> exec(
      List<String> args, String wd, Map<String, String> env) async {
    const APP = "restic";
    //const env = {"RESTIC_PASSWORD": "a"};
    try {
      final process = await Process.start(APP, args,
          environment: env,
          workingDirectory: wd,
          mode: ProcessStartMode.normal);
      return ProcessInfo(process, args[0]);
    } catch (e) {
      throw e;
    }
  }
}
