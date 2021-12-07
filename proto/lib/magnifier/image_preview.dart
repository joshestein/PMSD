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

  // We create an array of positions, one position for each keypoint
  List<Offset> positions = [
    const Offset(20, 20),
    const Offset(40, 40),
  ];

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
        for (Offset position in positions) ...[
          TouchBubble(
            position: position,
            radius: bubbleSize,
            onDragCallback: (Offset newPosition) {
              setState(() {
                _magnifierVisible = true;
                position = newPosition;
                _lastDragPosition = newPosition;
              });
            },
            onEndDragCallback: () => setState(() => _magnifierVisible = false),
          ),
        ],
      ],
    );
  }
}
