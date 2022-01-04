import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:opencv/opencv.dart';
import 'package:proto/magnifier/edge_painter.dart';
import 'package:proto/height_weight_confirmation.dart';
import 'package:proto/magnifier/magnifier.dart';
import 'package:proto/magnifier/touch_bubble.dart';
import 'package:proto/models/child.dart';
import 'package:proto/pose_detector.dart';

class ImagePreview extends StatefulWidget {
  final String imagePath;
  final Child child;

  const ImagePreview({Key? key, required this.imagePath, required this.child})
      : super(key: key);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late PoseDetector _poseDetector;
  late double _cmPerPixel;

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
    _cmPerPixel = OpenCV.getFastPixelsPerMM(widget.imagePath) * 10;

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

  double _getHeight() {
    double height = 0.0;
    for (int i = 0; i < positions.length - 1; i++) {
      Offset position = positions[i];
      Offset nextPosition = positions[i + 1];
      height += (position - nextPosition).distance * _cmPerPixel;
    }
    return height;
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
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _getImage(),
                    Magnifier(
                      position: _lastDragPosition,
                      visible: _magnifierVisible,
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: EdgePainter(
                          points: positions,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.5),
                        ),
                      ),
                    ),
                    for (Widget bubble in _getTouchBubbles()) bubble,
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HeightWeightConfirmation(
                                  child: widget.child,
                                  height: _getHeight(),
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.check),
                          backgroundColor: Colors.green,
                          heroTag: 'confirm',
                          tooltip: 'Accept pose',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
