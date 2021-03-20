import 'dart:async';

mixin ModelNotifier {
  final changeListener = StreamController.broadcast();

  void notifyListeners() {
    changeListener.add(this);
  }

  dispose() {
    print("closed");
    changeListener.close();
  }
}
