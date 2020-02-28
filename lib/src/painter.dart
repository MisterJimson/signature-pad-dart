import 'dart:async';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:signature_pad_widget/src/colors.dart';
import 'package:signature_pad_widget/src/point.dart';
import 'package:signature_pad_widget/src/signature_pad.dart';

class SignaturePadPainter extends CustomPainter {
  final List<SPPoint> allPoints;
  final SignaturePadOptions opts;
  Size lastSize;

  SignaturePadPainter(this.allPoints, this.opts);

  Future<Uint8List> getPng() async {
    if (lastSize == null) {
      return null;
    }
    var recorder = ui.PictureRecorder();
    var origin = Offset(0.0, 0.0);
    var paintBounds =
        Rect.fromPoints(lastSize.topLeft(origin), lastSize.bottomRight(origin));
    var canvas = Canvas(recorder, paintBounds);

    _paintPoints(canvas, lastSize, 0);

    // Add grey text in the bottom-right corner
    if (opts.signatureText != null) {
      var paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textDirection: ui.TextDirection.ltr,
        ),
      );
      var style = ui.TextStyle(color: Color.fromRGBO(100, 100, 100, 1.0));
      paragraphBuilder.pushStyle(style);
      paragraphBuilder.addText(opts.signatureText);
      paragraphBuilder.pop();
      var paragraph = paragraphBuilder.build();
      paragraph.layout(ui.ParagraphConstraints(width: lastSize.width));
      canvas.drawParagraph(
        paragraph,
        Offset(
          lastSize.width - paragraph.maxIntrinsicWidth,
          lastSize.height - paragraph.height,
        ),
      );
    }

    var picture = recorder.endRecording();
    var image =
        await picture.toImage(lastSize.width.round(), lastSize.height.round());
    var data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  @override
  void paint(Canvas canvas, Size size) {
    lastSize = size;
    _paintPoints(canvas, size, 0);
  }

  void _paintPoints(Canvas canvas, Size size, int startIdx) {
    for (var i = startIdx; i < allPoints.length; i++) {
      var point = allPoints[i];
      var paint = Paint()..color = colorFromColorString(opts.penColor);
      paint.strokeWidth = 5.0;
      var path = Path();
      var offset = Offset(point.point.x, point.point.y);
      path.moveTo(point.point.x, point.point.y);
      var pointSize = point.size;
      if (pointSize == null || pointSize.isNaN) {
        pointSize = opts.dotSize;
      }

      canvas.drawCircle(offset, pointSize, paint);

      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SignaturePadPainter oldDelegate) {
    return true;
  }
}
