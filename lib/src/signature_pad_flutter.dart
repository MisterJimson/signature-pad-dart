import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signature_pad_widget/src/mark.dart';
import 'package:signature_pad_widget/src/painter.dart';
import 'package:signature_pad_widget/src/point.dart';
import 'package:signature_pad_widget/src/signature_pad.dart';

class SignaturePadController {
  _SignaturePadDelegate _delegate;
  void clear() => _delegate?.clear();
  Future<List<int>> toPng() => _delegate?.getPng();
  bool get hasSignature => _delegate.hasSignature;
  Function onDrawStart;

  SignaturePadController({this.onDrawStart});
}

abstract class _SignaturePadDelegate {
  void clear();
  Future<List<int>> getPng();
  bool get hasSignature;
}

class SignaturePadWidget extends StatefulWidget {
  final SignaturePadOptions opts;
  final SignaturePadController controller;
  SignaturePadWidget(this.controller, this.opts);

  @override
  State<StatefulWidget> createState() {
    return SignaturePadState(controller, opts);
  }
}

class SignaturePadState extends State<SignaturePadWidget>
    with SignaturePadBase
    implements _SignaturePadDelegate {
  final SignaturePadController _controller;
  List<SPPoint> allPoints = [];
  bool _onDrawStartCalled = false;

  SignaturePadState(this._controller, SignaturePadOptions opts) {
    this.opts = opts;
    clear();
    on();
  }

  SignaturePadPainter _currentPainter;

  final StreamController<DragUpdateDetails> _updateSink =
      StreamController.broadcast();
  Stream<DragUpdateDetails> get _updates => _updateSink.stream;

  @override
  void initState() {
    super.initState();
    _controller._delegate = this;

    _updates.listen(handleDragUpdate);
  }

  @override
  Widget build(BuildContext context) {
    _currentPainter = SignaturePadPainter(allPoints, opts);
    return ClipRect(
      child: CustomPaint(
        painter: _currentPainter,
        child: GestureDetector(
          onTapDown: handleTap,
          onHorizontalDragUpdate: (d) => _updateSink.add(d),
          onVerticalDragUpdate: (d) => _updateSink.add(d),
          onHorizontalDragEnd: handleDragEnd,
          onVerticalDragEnd: handleDragEnd,
          onHorizontalDragStart: handleDragStart,
          onVerticalDragStart: handleDragStart,
          behavior: HitTestBehavior.opaque,
        ),
      ),
    );
  }

  void handleTap(TapDownDetails details) {
    handleDrawStartedCallback();

    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    var offs = Offset(x, y);
    RenderBox refBox = context.findRenderObject();
    offs = refBox.globalToLocal(offs);
    strokeBegin(Point(offs.dx, offs.dy));
    strokeEnd();
  }

  void handleDragUpdate(DragUpdateDetails details) {
    handleDrawStartedCallback();

    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    var offs = Offset(x, y);
    RenderBox refBox = context.findRenderObject();
    offs = refBox.globalToLocal(offs);
    strokeUpdate(Point(offs.dx, offs.dy));
  }

  void handleDrawStartedCallback() {
    if (!_onDrawStartCalled) {
      _onDrawStartCalled = true;
      if (_controller.onDrawStart != null) {
        _controller.onDrawStart();
      }
    }
  }

  void handleDragEnd(DragEndDetails details) {
    strokeEnd();
  }

  void handleDragStart(DragStartDetails details) {
    var x = details.globalPosition.dx;
    var y = details.globalPosition.dy;
    var offs = Offset(x, y);
    RenderBox refBox = context.findRenderObject();
    offs = refBox.globalToLocal(offs);
    strokeBegin(Point(offs.dx, offs.dy));
  }

  @override
  Mark createMark(double x, double y, [DateTime time]) {
    return Mark(x, y, time ?? DateTime.now());
  }

  @override
  void drawPoint(double x, double y, num size) {
    if (!_inBounds(x, y)) {
      return;
    }
    var point = Point(x, y);
    setState(() {
      allPoints.add(SPPoint(point, size));
    });
  }

  @override
  String toDataUrl([String type = 'image/png']) {
    return null;
  }

  @override
  void clear() {
    super.clear();
    if (mounted) {
      setState(() {
        _onDrawStartCalled = false;
        allPoints = [];
      });
    }
  }

  @override
  Future<List<int>> getPng() {
    return _currentPainter.getPng();
  }

  @override
  bool get hasSignature => _currentPainter.allPoints.isNotEmpty;

  bool _inBounds(double x, double y) {
    var size = _currentPainter.lastSize;
    return x >= 0 && x < size.width && y >= 0 && y < size.height;
  }
}
