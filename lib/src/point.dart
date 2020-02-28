import 'dart:math';

class SPPoint {
  final Point point;
  final double size;

  SPPoint(this.point, this.size);

  @override
  String toString() => 'SPPoint $point $size';
}
