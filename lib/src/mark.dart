import 'dart:math';

class Mark extends Point<double> {
  final DateTime time;

  Mark(double x, double y, this.time) : super(x, y);

  int get timeMs => time.millisecondsSinceEpoch;

  double velocityFrom(Mark start) {
    if (timeMs == start.timeMs) {
      return 1.0;
    }
    var result = distanceTo(start) / (timeMs - start.timeMs);
    return result;
  }
}
