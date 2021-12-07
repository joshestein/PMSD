import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/magnifier/magnifier.dart';
import 'package:proto/magnifier/touch_bubble.dart';

class ImagePreview extends StatefulWidget {
  // TODO: pass image from image_picker to constructor
  const ImagePreview({Key? key}) : super(key: key);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  static const double bubbleSize = 20;

  Offset position = const Offset(20, 20);
  double currentBubbleSize = bubbleSize;
  bool magnifierVisible = false;

  @override
  void initState() {
    currentBubbleSize = bubbleSize;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Magnifier(
          position: position,
          visible: magnifierVisible,
          child: const Image(
            image: AssetImage('assets/hanging.jpg'),
          ),
        ),
        TouchBubble(
          position: position,
          onStartDragging: _startDragging,
          onDrag: _drag,
          onEndDragging: _endDragging,
          bubbleSize: currentBubbleSize,
        )
      ],
    );
  }

  void _startDragging(Offset newPosition) {
    setState(() {
      position = newPosition;
      magnifierVisible = true;
      currentBubbleSize = bubbleSize * 1.5;
    });
  }

  void _drag(Offset newPosition) {
    setState(() {
      position = newPosition;
    });
  }

  void _endDragging() {
    setState(() {
      magnifierVisible = false;
      currentBubbleSize = bubbleSize;
    });
  }
}
