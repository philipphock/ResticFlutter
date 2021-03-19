import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/resticjsons.dart';

class ContextPayload<P> {
  final BuildContext context;
  final P payload;
  ContextPayload(this.context, this.payload);
}

class StreamWrapper<P> {
  StreamController<P> _ctrl;
  Stream<P> _stream;

  StreamWrapper() {
    _ctrl = StreamController<P>();
    _stream = _ctrl.stream;
  }

  void emit(P p) {
    this._ctrl.add(p);
  }

  Stream<P> get stream => _stream;
}

class BroadcastStream<P> {
  StreamController<P> _ctrl;
  Stream<P> _stream;

  BroadcastStream() {
    _ctrl = StreamController<P>.broadcast();
    _stream = _ctrl.stream;
  }

  void emit(P p) {
    this._ctrl.add(p);
  }

  Stream<P> get stream => _stream;
}

class $ {
  $._();
  static final StreamController<ContextPayload<ListItemModel>> itemRemove =
      new StreamController.broadcast();
  static final StreamController<ContextPayload<ListItemModel>> itemEdited =
      new StreamController.broadcast();
  static final StreamController<ContextPayload<ListItemModel>> itemInspect =
      new StreamController.broadcast();
  static final StreamController<ContextPayload<ListItemModel>>
      itemEnqueuButton = new StreamController.broadcast();

  static final StreamController<ContextPayload<Snapshot>> snapshotRemoved =
      new StreamController.broadcast();
}
