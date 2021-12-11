import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/magnifier/magnifier.dart';
import 'package:proto/magnifier/touch_bubble.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  static const double bubbleSize = 20;
  late PoseDetector _poseDetector;

  // We create an array of positions, one position for each keypoint
  List<Offset> positions = [
    const Offset(20, 20),
    const Offset(40, 40),
  ];
  Offset _lastDragPosition = const Offset(0, 0);
  bool _magnifierVisible = false;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    _poseDetector = PoseDetector(widget.imagePath);
    super.initState();
  }

  Widget image() {
    return kDebugMode
        ? Image.asset('assets/hanging.jpg')
        // Why network for web?
        // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
        : kIsWeb
            ? Image.network(widget.imagePath)
            : Image.file(File(widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Magnifier(
          position: _lastDragPosition,
          visible: _magnifierVisible,
          child: image(),
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
