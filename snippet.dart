import 'dart:io';
import 'dart:convert';

main() async {
  const env = {"RESTIC_PASSWORD": "a"};
  final process = await Process.start(
      'restic', ["-r", r"c:\test\repos", "snapshots"],
      environment: env);
  process.stderr.transform(utf8.decoder).forEach(print);
  process.stdout.transform(utf8.decoder).forEach(print);
}
