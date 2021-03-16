mixin Log {
  void print(Object o) {
    print("$this: $o");
  }
}

void log(String origin, Object o) {
  print("$origin: $o");
}
