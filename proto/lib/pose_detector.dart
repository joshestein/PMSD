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

class PoseDetector {
  final String imagePath;

  PoseDetector(this.imagePath);

  Future loadModel() async {
    await Tflite.loadModel(
        model: 'assets/posenet_mv1_075_float_from_checkpoints.tflite');
  }

  Future getImageSize() async {
    var image = File(imagePath);
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    var width = decodedImage.width.toDouble();
    var height = decodedImage.height.toDouble();
    return [width, height];
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

  Future<HashMap<String, List<double>>> getKeypoints(Size screen) async {
    await loadModel();
    var imageSize = await getImageSize();
    var recognitions = await poseNet(File(imagePath));

    double width = imageSize[0];
    double height = imageSize[0];

    double factorX = screen.width;
    double factorY = height / width * screen.width;

    HashMap<String, List<double>> hash = HashMap();
    for (var re in recognitions) {
      for (var keypoints in re["keypoints"].values) {
        var x = keypoints["x"] * factorX;
        var y = keypoints["y"] * factorY;
        hash.putIfAbsent(keypoints["part"], () => [x, y]);
      }
    }
    print(hash);
    return hash;
  }
}
