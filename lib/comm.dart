import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hello_world/views/ItemListView.dart';

class ContextPayload<P> {
  final BuildContext context;
  final P payload;
  ContextPayload(this.context, this.payload);
}

class BroadcastStream<P> {
  StreamController<P> _ctrl;
  Stream<P> _stream;

  BroadcastStream() {
    _ctrl = StreamController<P>();
    _stream = _ctrl.stream.asBroadcastStream();
  }

  void emit(P p) {
    this._ctrl.add(p);
  }

  Stream<P> get stream => _stream;
}

class $ {
  $._();
  static final BroadcastStream<ContextPayload<ListItemModel>> itemRemove =
      new BroadcastStream();
  static final BroadcastStream<ContextPayload<ListItemModel>> itemEdit =
      new BroadcastStream();
  static final BroadcastStream<ContextPayload<ListItemModel>> itemInspect =
      new BroadcastStream();
  static final BroadcastStream<ContextPayload<ListItemModel>> itemEnqueuButton =
      new BroadcastStream();
}
