class Snapshot {
  String id;
  List<String> paths = [];
  String time;

  Snapshot.fromJSON(dynamic d) {
    id = d['id'];
    time = d['time'];
    time =
        "${time.substring(8, 10)}.${time.substring(5, 7)}.${time.substring(0, 4)} ${time.substring(11, 13)}:${time.substring(14, 16)}:${time.substring(17, 18)}";

    var l = d["paths"] as List<dynamic>;

    l.forEach((element) {
      paths.add(element.toString());
    });
  }

  @override
  String toString() {
    return """
      id: $id
      paths: [${paths.join(',')}]
      time: $time
    """;
  }
}

class SnapshotFile {
  String name;
  bool isDir;
  String path;

  SnapshotFile.fromJSON(dynamic d) {
    name = d['name'];
    isDir = d['type'] == "dir";
    path = d['path'];
  }
  @override
  String toString() {
    return "file: $name ($isDir): $path";
  }
}
