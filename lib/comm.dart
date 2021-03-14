import 'dart:async';

import 'package:hello_world/ItemListView.dart';

class $ {
  $._();
  static final StreamController<MyListItem> itemRemoved =
      StreamController<MyListItem>();
}
