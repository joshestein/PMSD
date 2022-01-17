// TODO: use newer package with newer pose model
// class PoseDetector {
//   static const int INPUT_SIZE = 256;
//   final _modelName = 'model_movenet_singlepose_thunder_3.tflite';
//   late Interpreter _interpreter;

//   PoseDetector() {
//     _loadModel();
//   }

//   void _loadModel() async {
//     _interpreter = await Interpreter.fromAsset(_modelName);
//   }

//   // Input is a [1, height, width, 3] tensor
//   // Returns a [1, 1, 17, 3] array representing predicted coordinates and scores
//   List<double> detectKeyPoints() {
//     _interpreter.run();
//   }
// }

import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite/tflite.dart';

const List<String> inclusionKeypoints = [
  'leftEye',
  'leftShoulder',
  'leftHip',
  'leftKnee',
  'leftAnkle',
];

/// Runs TensorFlow Lite on a given image returning a list of keypoints.
class PoseDetector {
  final String imagePath;

  PoseDetector(this.imagePath);

  Future loadModel() async {
    await Tflite.loadModel(
        model: 'assets/posenet_mv1_075_float_from_checkpoints.tflite');
  }

  Future poseNet(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 1,
    );

    // print(recognitions);
    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
    return recognitions;
  }

  /// Returns a hashmap of keypoints for each body part.
  /// We use a LinkedHashMap to preserve the order of the keypoints.
  Future<LinkedHashMap<String, List<double>>> getKeypoints(Size screen) async {
    await loadModel();
    var recognitions = await poseNet(File(imagePath));

    LinkedHashMap<String, List<double>> hash = LinkedHashMap();
    for (var re in recognitions) {
      for (var keypoints in re["keypoints"].values) {
        // We only include the keypoints that we want to show.
        // This was arbitrarily chosen to the left side of the body.
        if (inclusionKeypoints.contains(keypoints['part'])) {
          var x = keypoints["x"];
          var y = keypoints["y"];
          hash.putIfAbsent(keypoints["part"], () => [x, y]);
        }
      }
    }
    return hash;
  }
}
