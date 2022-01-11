import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A draggable bubble that stores its [position].
class TouchBubble extends StatefulWidget {
  const TouchBubble({
    Key? key,
    required this.position,
    required this.onDragCallback,
    required this.onEndDragCallback,
  }) : super(key: key);

  final Offset position;
  final Function onDragCallback;
  final Function onEndDragCallback;

  @override
  _TouchBubbleState createState() => _TouchBubbleState();
}

class _TouchBubbleState extends State<TouchBubble> {
  static const double initialSize = 20;
  late Offset _position;
  late double _currentRadius;

  @override
  void initState() {
    _position = widget.position;
    _currentRadius = initialSize;
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
      _currentRadius = initialSize * 1.5;
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
      _currentRadius = initialSize;
    });
    widget.onEndDragCallback();
  }
}
