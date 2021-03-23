import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:restic_ui/models/FileTreeElement.dart';
import 'package:restic_ui/models/ListItemModel.dart';
import 'package:restic_ui/process/ResticProxy.dart';
import 'package:restic_ui/process/resticjsons.dart';
import 'package:restic_ui/util/Filepicker.dart';
import 'package:restic_ui/util/Log.dart';
import 'package:restic_ui/util/dialog.dart';

class ItemTreeViewArgs {
  final ListItemModel model;
  final Snapshot snap;

  ItemTreeViewArgs(this.model, this.snap);
}

class ItemTreeView extends StatefulWidget {
  static const String ROUTE = "/tree";

  @override
  State<StatefulWidget> createState() => ItemTreeViewState();
}

class ItemTreeViewState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    ItemTreeViewArgs args = ModalRoute.of(context).settings.arguments;

    //print(item.heading);
    var fb = FutureBuilder<List<SnapshotFile>>(
      future: ResticProxy.getFiles(args.model.repo, args.snap.id, ".",
          args.model.password), //item.repo, "latest" item.password
      builder: (context, AsyncSnapshot<List<SnapshotFile>> data) {
        if (!data.hasData) {
          return Container(
            child: Align(child: CircularProgressIndicator()),
          );
        } else {
          return Container(
            child: TreeWidget(data.data, args.model, args.snap),
          );
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tree"),
        iconTheme: IconThemeData(
          color: Colors.white70, //change your color here
        ),
      ),
      body: fb,
    );
  }
}

class TreeWidget extends StatelessWidget with Log {
  final List<SnapshotFile> items;
  final ListItemModel model;
  final Snapshot snap;
  TreeViewController _treeViewController;
  Node<SnapshotFile> root;

  TreeWidget(this.items, this.model, this.snap) {
    var tree = buildTree(items);
    var compatibleTree = toNodes(tree);
    root = compatibleTree;
    _treeViewController = TreeViewController(children: root.children);
  }

  @override
  Widget build(BuildContext context) {
    var theme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
        type: ExpanderType.caret,
        modifier: ExpanderModifier.none,
        position: ExpanderPosition.start,
        color: Colors.red.shade800,
        size: 20,
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w800,
        color: Colors.grey,
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: ColorScheme.dark(),
    );

    return Container(
      child: TreeView(
        controller: _treeViewController,
        supportParentDoubleTap: true,
        theme: theme,
        onNodeDoubleTap: (key) async {
          var ret = await showAlertDialog(context, "Extract?", "$key",
              [DialogOption("extract", 1), DialogOption("cancel", 0)]);
          if (ret == 1) {
            var folder = await pickFolder(context);
            if (folder != null) {
              showWaitDialog(context, "extracting...");

              await ResticProxy.extract(
                  model.repo, key, snap.id, folder, ".", model.password);
              Navigator.of(context).pop();
              await showAlertDialog(
                  context, "Extraction complete", "", DialogOption.ok());
            }
          }
        },

        /*
        onNodeTap: (key) {
          Node selectedNode = _treeViewController.getNode(key);
          FileTreeElement selectedModel = selectedNode.data;
        },
        */
      ),
    );
  }
}

FileTreeElement<SnapshotFile> buildTree(List<SnapshotFile> files) {
  var folders = Map<String, FileTreeElement<SnapshotFile>>();
  var stack = <FileTreeElement<SnapshotFile>>[];
  var root = FileTreeElement<SnapshotFile>(SnapshotFile.root());
  //(key: "0", label: "root");

  files.forEach((f) {
    var node = FileTreeElement<SnapshotFile>(f);

    var parent = f.parent;
    var dir = f.path;

    if (parent == null) {
      parent = "";
    }

    if (f.isDir && !folders.containsKey(dir)) {
      folders[dir] = node;
      if (root?.children?.length == 0) {
        root.children.add(node);
      }
    }

    if (folders.containsKey(parent)) {
      folders[parent].children.add(node);
    } else {
      if (!f.isDir) {
        stack.add(node);
      }
    }
  });

  stack.forEach((s) {
    root.children.add(s);
  });

  return root;
}

Node<SnapshotFile> toNodes(FileTreeElement<SnapshotFile> f) {
  return Node<SnapshotFile>(
      key: f.data.path,
      label: f.data.name,
      data: f.data,
      children: f.children.map((child) => toNodes(child)).toList());
}
