import 'package:flutter/widgets.dart';

class MagnifierPainter extends CustomPainter {
  MagnifierPainter(this.color, this.strokeWidth);

  final double strokeWidth;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    _drawCircle(canvas, size);
    _drawCrosshair(canvas, size);
  }

  void _drawCircle(Canvas canvas, Size size) {
    Paint paintObject = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      size.center(Offset.zero),
      size.longestSide / 2,
      paintObject,
    );
  }

  void _drawCrosshair(Canvas canvas, Size size) {
    Paint crossPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth / 2;

    double crossSize = size.longestSide * 0.04;

    canvas.drawLine(
      size.center(Offset(-crossSize, -crossSize)),
      size.center(Offset(crossSize, crossSize)),
      crossPaint,
    );

    canvas.drawLine(
      size.center(Offset(crossSize, -crossSize)),
      size.center(Offset(-crossSize, crossSize)),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
