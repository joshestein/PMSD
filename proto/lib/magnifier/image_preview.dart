import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/edge_painter.dart';
import 'package:proto/magnifier/magnifier.dart';
import 'package:proto/magnifier/touch_bubble.dart';
import 'package:proto/pose_detector.dart';

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
  List<Offset> positions = [];
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

  Future<List<Offset>> _getInitialPosePositions(Size size) async {
    if (positions.isEmpty) {
      var keypoints = await _poseDetector.getKeypoints(size);
      keypoints.forEach((key, value) {
        Offset offset = Offset(value[0], value[1]);
        positions.add(offset);
      });
    }

    return positions;
  }

  Widget _getImage() {
    // Why network for web?
    // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
    return kIsWeb
        ? Image.network(widget.imagePath)
        : Image.file(File(widget.imagePath));
  }

  List<Widget> _getTouchBubbles() {
    List<Widget> list = [];
    for (int i = 0; i < positions.length; i++) {
      Offset position = positions[i];
      list.add(
        TouchBubble(
          position: position,
          radius: bubbleSize,
          onDragCallback: (Offset newPosition) {
            setState(() {
              _magnifierVisible = true;
              position = newPosition;
              positions[i] = newPosition;
              _lastDragPosition = newPosition;
            });
          },
          onEndDragCallback: () => setState(() => _magnifierVisible = false),
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<List<Offset>>(
        future: _getInitialPosePositions(size),
        builder: (BuildContext context, AsyncSnapshot<List<Offset>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            children = [
              Stack(
                children: [
                  Magnifier(
                    position: _lastDragPosition,
                    visible: _magnifierVisible,
                    child: _getImage(),
                  ),
                  for (Widget bubble in _getTouchBubbles()) bubble,
                  CustomPaint(
                    painter: EdgePainter(
                      points: positions,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.5),
                    ),
                  ),
                ],
              )
            ];
          } else {
            children = [
              const Center(
                child: CircularProgressIndicator(),
              ),
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text('Processing...'))),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        });
  }
}
