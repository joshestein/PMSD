import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/magnifier/magnifier_painter.dart';

class Magnifier extends StatefulWidget {
  const Magnifier(
      {Key? key,
      required this.position,
      this.diameter = 80.0,
      this.scale = 1.5})
      : super(key: key);

  final Offset position;
  final double diameter;
  final double scale;

  @override
  State<Magnifier> createState() => _MagnifierState();
}

class _MagnifierState extends State<Magnifier> {
  late Matrix4 _matrix;

  @override
  void initState() {
    _calculateMatrix();

    super.initState();
  }

  @override
  void didUpdateWidget(Magnifier oldWidget) {
    super.didUpdateWidget(oldWidget);

    _calculateMatrix();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      // Align to top left or top right, depending on the position of touch bubble
      alignment: _getAlignment(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.matrix(_matrix.storage),
          child: CustomPaint(
            painter:
                MagnifierPainter(Theme.of(context).colorScheme.secondary, 2),
            size: Size(widget.diameter, widget.diameter),
          ),
        ),
      ),
    );
  }

  void _calculateMatrix() {
    setState(() {
      double newX = widget.position.dx - (widget.diameter / 2 / widget.scale);
      double newY =
          widget.position.dy - (widget.diameter / 2 / widget.scale) + 18.33;

      // Order of operations is important. First scale, then translate.
      final Matrix4 updatedMatrix = Matrix4.identity()
        ..scale(widget.scale, widget.scale)
        ..translate(-newX, -newY);

      _matrix = updatedMatrix;
    });
  }

  Alignment _getAlignment() {
    return _bubbleCrossesMagnifier() ? Alignment.topRight : Alignment.topLeft;
  }

  bool _bubbleCrossesMagnifier() {
    return widget.position.dx < widget.diameter &&
        widget.position.dy < widget.diameter;
  }
}
