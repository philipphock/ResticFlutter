/// Replaces all non-printable characters in value with a space.
/// tabs, newline etc are all considered non-printable.
String replaceNoPrintable(String value, {String replaceWith = ' '}) {
  var charCodes = <int>[];

  for (final codeUnit in value.codeUnits) {
    if (isPrintable(codeUnit)) {
      charCodes.add(codeUnit);
    } else {
      if (replaceWith.isNotEmpty) {
        charCodes.add(replaceWith.codeUnits[0]);
      }
    }
  }

  return String.fromCharCodes(charCodes);
}

bool isPrintable(int codeUnit) {
  var printable = true;

  if (codeUnit < 33) printable = false;
  if (codeUnit >= 127) printable = false;

  return printable;
}
