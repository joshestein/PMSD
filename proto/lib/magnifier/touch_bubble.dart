import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TouchBubble extends StatefulWidget {
  const TouchBubble(
      {Key? key,
      required this.position,
      required this.onDragCallback,
      required this.onEndDragCallback,
      required this.radius})
      : super(key: key);

  final Offset position;
  final double radius;
  final Function onDragCallback;
  final Function onEndDragCallback;

  @override
  _TouchBubbleState createState() => _TouchBubbleState();
}

class _TouchBubbleState extends State<TouchBubble> {
  late Offset _position;
  late double _currentRadius;

  @override
  void initState() {
    _position = widget.position;
    _currentRadius = widget.radius;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _position.dy - _currentRadius / 2,
      left: _position.dx - _currentRadius / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: _startDragging,
        onPanUpdate: _drag,
        onPanEnd: (_) => _endDragging(),
        child: Container(
          width: _currentRadius,
          height: _currentRadius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  void _startDragging(DragStartDetails details) {
    // We offset by magic 80 to accout for size of magnifier.
    // TODO: calculate this dynamically
    Offset position = details.globalPosition.translate(0, -80);
    setState(() {
      _position = position;
      _currentRadius = widget.radius * 1.5;
    });

    widget.onDragCallback(position);
  }

  void _drag(DragUpdateDetails details) {
    Offset position = details.globalPosition.translate(0, -80);
    setState(() {
      _position = position;
    });
    widget.onDragCallback(position);
  }

  void _endDragging() {
    setState(() {
      _currentRadius = widget.radius;
    });
    widget.onEndDragCallback();
  }
}
