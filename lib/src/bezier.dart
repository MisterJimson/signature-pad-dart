import 'dart:math';
import 'package:signature_pad_widget/src/mark.dart';

class Bezier {
  final Mark startPoint;
  final Point control1;
  final Point control2;
  final Mark endPoint;

  Bezier(this.startPoint, this.control1, this.control2, this.endPoint);

  double length() {
    var steps = 10;
    var length = 0.0;
    var px;
    var py;

    for (var i = 0.0; i <= steps; i += 1) {
      var t = i / steps;
      var cx = _point(
        t,
        startPoint.x,
        control1.x,
        control2.x,
        endPoint.x,
      );
      var cy = _point(
        t,
        startPoint.y,
        control1.y,
        control2.y,
        endPoint.y,
      );
      if (i > 0) {
        var xdiff = cx - px;
        var ydiff = cy - py;
        length += sqrt((xdiff * xdiff) + (ydiff * ydiff));
      }
      px = cx;
      py = cy;
    }

    return length;
  }

  double _point(double t, double start, double c1, double c2, double end) {
    return (start * (1.0 - t) * (1.0 - t) * (1.0 - t)) +
        (3.0 * c1 * (1.0 - t) * (1.0 - t) * t) +
        (3.0 * c2 * (1.0 - t) * t * t) +
        (end * t * t * t);
  }
}
