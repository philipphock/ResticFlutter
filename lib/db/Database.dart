import 'dart:io';

import 'package:restic_ui/util/Log.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

typedef DBCallback = Future Function(StoreRef store, Transaction trx);

class CrudDB with Log {
  static const String RESTIC_FOLDER = "restic_ui";
  static const String DB_NAME = "resticui.db";
  static CrudDB _i;
  DatabaseFactory _database;

  String get _dbwd {
    return [_userPath, RESTIC_FOLDER].join(Platform.pathSeparator);
  }

  String get _dbpath {
    return [_dbwd, DB_NAME].join(Platform.pathSeparator);
  }

  CrudDB._internal() {
    var create = !Directory(_dbwd).existsSync();
    if (create) {
      Directory(_dbwd).createSync();
    }
    _database = databaseFactoryIo;
  }

  Future<int> create(Map<String, dynamic> o) async {
    int ret = -1;
    await _query((store, trx) async {
      ret = await store.add(trx, o);
    });
    return ret;
  }

  Future update(int id, Map<String, dynamic> o) async {
    await _query((store, trx) async {
      await store.record(id).update(trx, o);
    });
  }

  Future delete(int id) async {
    await _query((store, trx) async {
      await store.record(id).delete(trx);
    });
  }

  Future<List<Map<String, dynamic>>> read() async {
    List<Map<String, dynamic>> l = [];

    await _query((store, trx) async {
      final ret = await store.find(trx);
      ret.forEach((element) {
        var id = element.key;
        var content = element.value as Map<String, dynamic>;
        Map<String, dynamic> m2 = Map.from(content);
        m2["_key"] = id;
        l.add(m2);
      });
      return ret;
    });

    return l;
  }

  Future _query(DBCallback cb) async {
    var db = await _database.openDatabase(_dbpath);
    final store = intMapStoreFactory.store('repos');
    await db.transaction((txn) async {
      await cb(store, txn);
    });
    await db.close();
  }

  factory CrudDB() {
    if (_i == null) {
      _i = CrudDB._internal();
    }
    return _i;
  }

  String get _userPath {
    //maybe replace by getApplicationDocumentsDirectory
    /*static Future _initSembast() async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    final databasePath = join(appDir.path, "sembast.db");
    final database = await databaseFactoryIo.openDatabase(databasePath);
    */

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
