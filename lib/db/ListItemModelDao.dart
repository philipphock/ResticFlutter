import 'package:restic_ui/db/Database.dart';
import 'package:restic_ui/models/ListItemModel.dart';

class ListItemModelDao {
  static Future<List<ListItemModel>> loadAllItems() async {
    var db = CrudDB();
    List<Map<String, dynamic>> r = await db.read();
    return r.map<ListItemModel>((e) => ListItemModel.fromJson(e)).toList();
  }

  static Future updateItem(ListItemModel m) async {
    var db = CrudDB();
    await db.update(m.dbId, m.toJson());
  }

  static Future deleteItem(ListItemModel m) async {
    var db = CrudDB();
    await db.delete(m.dbId);
  }

  static Future createItem(ListItemModel m) async {
    var db = CrudDB();
    int id = await db.create(m.toJson());
    m.dbId = id;
  }
}
