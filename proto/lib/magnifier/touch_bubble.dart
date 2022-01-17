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
  late double _currentRadius;

  @override
  void initState() {
    _currentRadius = initialSize;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // The positioning needs to be offset to account for the size of the bubble.
      // That is, we need to shift the center of the bubble to the top left.
      // This is equivalent to shifting the top left itself.
      top: widget.position.dy - _currentRadius / 2,
      left: widget.position.dx - _currentRadius / 2,
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
    setState(() {
      _currentRadius = initialSize * 1.5;
    });
  }

  void _drag(DragUpdateDetails details) {
    widget.onDragCallback(details.delta);
  }

  void _endDragging() {
    setState(() {
      _currentRadius = initialSize;
    });
    widget.onEndDragCallback();
  }
}
