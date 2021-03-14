import 'dart:async';

import 'package:hello_world/views/ItemListView.dart';

class $ {
  $._();
  static final StreamController<ListItemModel> itemRemoved =
      StreamController<ListItemModel>();
}
