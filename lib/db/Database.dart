import 'dart:io';

class DB {
  static DB _i;
  String get dbwd {
    return "";
  }

  DB._internal() {
    //if (Directiory()) {}
  }

  factory DB() {
    if (_i == null) {
      _i = DB._internal();
    }
    return _i;
  }

  String get userPath {
    String home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    } else {
      throw Exception("OS not supported!");
    }
    return home;
  }
}
