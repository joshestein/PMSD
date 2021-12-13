import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/magnifier/magnifier_painter.dart';

class Magnifier extends StatefulWidget {
  const Magnifier(
      {Key? key,
      required this.child,
      required this.position,
      this.visible = false,
      this.radius = 80.0,
      this.scale = 1.5})
      : super(key: key);

  final Widget child;
  final Offset position;
  final bool visible;
  final double radius;
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
    return Stack(
      children: [
        widget.child,
        if (widget.visible) _getMagnifier(context),
      ],
    );
  }

  Widget _getMagnifier(BuildContext context) {
    return Align(
      // Align to top left or top right, depending on the position of touch bubble
      alignment: _getAlignment(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.matrix(_matrix.storage),
          child: CustomPaint(
            painter:
                MagnifierPainter(Theme.of(context).colorScheme.secondary, 2),
            size: Size(widget.radius, widget.radius),
          ),
        ),
      ),
    );
  }

  void _calculateMatrix() {
    setState(() {
      double newX = widget.position.dx - (widget.radius / 2 / widget.scale);
      // TODO: fix this magic 25
      double newY =
          widget.position.dy - (widget.radius / 2 / widget.scale) + 25;

      // if (_bubbleCrossesMagnifier()) {
      //   final box = context.findRenderObject() as RenderBox;
      //   newX -= ((box.size.width - widget.radius) / widget.scale);
      // }

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
    return widget.position.dx < widget.radius &&
        widget.position.dy < widget.radius;
  }
}
