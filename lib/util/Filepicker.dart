import 'dart:async';
import 'dart:io';

import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';

Future<String> pickFolder(BuildContext context) async {
  final isWin = Platform.isWindows;
  if (isWin) {
    return _pickFolderWin(context);
  }
  var drive = "/";
  /*
  if (isWin) {
    drive = await showInputDialog(context, "Drive", "drive letter", len: 1);
    if (drive == null) {
      return null;
    }
    drive = "$drive:/";
  }
  */
  var p = await FilesystemPicker.open(
      context: context,
      fsType: FilesystemType.folder,
      rootDirectory: Directory.fromUri(Uri.file(drive, windows: isWin)));
  return p;
}

String _pickFolderWin(BuildContext context) {
  final file = DirectoryPicker()..title = 'Select a folder';
  final result = file.getDirectory();
  return result?.path;
}
