import 'dart:async';

import 'package:hello_world/views/ItemListView.dart';

class $ {
  $._();
  static final StreamController<MyListItem> itemRemoved =
      StreamController<MyListItem>();
}
