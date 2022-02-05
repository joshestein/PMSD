import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:opencv/opencv.dart';
import 'package:proto/magnifier/edge_painter.dart';
import 'package:proto/measurement/measurement_data.dart';
import 'package:proto/magnifier/magnifier.dart';
import 'package:proto/magnifier/touch_bubble.dart';
import 'package:proto/models/child.dart';
import 'package:proto/models/measurement.dart';
import 'package:proto/pose_detector.dart';

/// Runs pose inference, and displays configurable keypoints in a stack above the image.
/// The positions can be updated by dragging the keypoints.
class ImagePreview extends StatefulWidget {
  final String imagePath;
  final Child child;
  final Size originalSize;
  final Size renderedSize;

  const ImagePreview(
      {Key? key,
      required this.imagePath,
      required this.child,
      required this.originalSize,
      required this.renderedSize})
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

  // Offsets
  Size _transformedSize = const Size(1, 1);
  Offset _transformOffset = const Offset(0, 0);

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );

    _calculateDimensions();
    _poseDetector = PoseDetector(widget.imagePath);
    _cmPerPixel = OpenCV.getFastPixelsPerMM(widget.imagePath) * 10;

    super.initState();
  }

  /// Calculates the true rendered size of the image.
  /// The scaling factors for width and height are stored in [_transformedSize].
  /// The offset (to shift the image to the center) is stored in [_transformOffset].
  void _calculateDimensions() {
    double widthFactor = widget.renderedSize.width / widget.originalSize.width;
    double heightFactor =
        widget.renderedSize.height / widget.originalSize.height;
    double sizeFactor = min(widthFactor, heightFactor);

    var transformedHeight = widget.originalSize.height * sizeFactor;
    var topOffset = ((widget.renderedSize.height - transformedHeight) / 2);

    var transformedWidth = widget.originalSize.width * sizeFactor;
    var leftOffset = ((widget.renderedSize.width - transformedWidth) / 2);
    _transformOffset = Offset(leftOffset, topOffset);
    _transformedSize = Size(transformedWidth, transformedHeight);
  }

  Future<List<Offset>> _getInitialPosePositions(Size size) async {
    if (positions.isEmpty) {
      var keypoints = await _poseDetector.getKeypoints(size);
      keypoints.forEach((key, value) {
        Offset offset = Offset(value[0], value[1])
            .scale(_transformedSize.width, _transformedSize.height)
            .translate(_transformOffset.dx, _transformOffset.dy);
        positions.add(offset);
      });
    }

    return positions;
  }

  // Builds a list of draggable TouchBubbles, one for each pose keypoint.
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
              positions[i] += newPosition;
              _lastDragPosition = positions[i];
            });
          },
          onEndDragCallback: () => setState(() => _magnifierVisible = false),
        ),
      );
    }
    return list;
  }

  // Calculate the heigth of the baby by taking a vector sum of the keypoints, and converting to cm.
  double _getHeight() {
    double height = 0.0;
    for (int i = 0; i < positions.length - 1; i++) {
      Offset position = positions[i];
      Offset nextPosition = positions[i + 1];
      height += (position - nextPosition).distance;
    }
    return (height - _transformOffset.dy / 2) * _cmPerPixel;
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
                  fit: StackFit.expand,
                  children: [
                    if (_magnifierVisible)
                      Magnifier(position: _lastDragPosition),
                    CustomPaint(
                      painter: EdgePainter(
                        points: positions,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
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
                                builder: (context) => MeasurementData(
                                  child: widget.child,
                                  measurement: Measurement(
                                    childId: widget.child.id!,
                                    height: _getHeight(),
                                  ),
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
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                      child: Text('Processing...',
                          style: Theme.of(context).textTheme.headline5))),
            ];
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          );
        });
  }
}
