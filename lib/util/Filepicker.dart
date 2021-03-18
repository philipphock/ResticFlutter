import 'dart:io';

import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:restic_ui/util/dialog.dart';

Future<String> pickFolder(BuildContext context) async {
  final isWin = Platform.isWindows;
  var drive = "/";
  if (isWin) {
    drive = await showInputDialog(context, "Drive", "drive letter", len: 1);
    if (drive == null) {
      return null;
    }
    drive = "$drive:/";
  }

  var p = await FilesystemPicker.open(
      context: context,
      fsType: FilesystemType.folder,
      rootDirectory: Directory.fromUri(Uri.file(drive, windows: isWin)));
  return p;
}
