import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TouchBubble extends StatelessWidget {
  const TouchBubble(
      {Key? key,
      required this.position,
      required this.onStartDragging,
      required this.onDrag,
      required this.onEndDragging,
      required this.bubbleSize})
      : super(key: key);

  final Offset position;
  final double bubbleSize;
  final Function onStartDragging;
  final Function onDrag;
  final Function onEndDragging;

  @override
  Widget build(BuildContext context) {
    print('TouchBubble x $position');
    return Positioned(
      top: position.dy - bubbleSize / 2,
      left: position.dx - bubbleSize / 2,
      child: GestureDetector(
        onPanStart: (details) => onStartDragging(details.globalPosition),
        onPanUpdate: (details) => onDrag(details.globalPosition),
        onPanEnd: (_) => onEndDragging(),
        child: Container(
          width: bubbleSize,
          height: bubbleSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
