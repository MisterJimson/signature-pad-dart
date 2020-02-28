import 'package:flutter/rendering.dart';

Color colorFromColorString(String s) =>
    _ColorFormatter()._convertColorFromHex(s);

class _ColorFormatter {
  Color _convertColorFromHex(String hexVal) {
    var r = (int.parse(hexVal.substring(1, 3), radix: 16)).toRadixString(10);
    var g = (int.parse(hexVal.substring(3, 5), radix: 16)).toRadixString(10);
    var b = (int.parse(hexVal.substring(5), radix: 16)).toRadixString(10);

    return Color.fromRGBO(int.parse(r), int.parse(g), int.parse(b), 1.0);
  }

  Color flutterColor(String hexColor) {
    return _convertColorFromHex(hexColor);
  }
}