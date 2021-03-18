class FileTreeElement<T> {
  T data;
  List<FileTreeElement<T>> children = [];
  FileTreeElement(this.data);

  @override
  String toString() {
    var c = children.map((e) => e.toString());

    return "${data.toString()}\n    ${c.toString()}";
  }
}
