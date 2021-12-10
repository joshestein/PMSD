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

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tflite/tflite.dart';

class PoseDetector extends StatefulWidget {
  const PoseDetector({Key? key, required this.imagePath}) : super(key: key);

  final String imagePath;

  @override
  _PoseDetectorState createState() => _PoseDetectorState();
}

class _PoseDetectorState extends State<PoseDetector> {
  File? _image;
  bool _busy = false;
  List _recognitions = [];
  double _imageHeight = 0;
  double _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    _busy = true;

    loadModel().then((value) {
      setState(() {
        _busy = false;
      });
    });
  }

  Future loadModel() async {
    await Tflite.loadModel(
        model: 'assets/posenet_mv1_075_float_from_checkpoints.tflite');
  }

  Future predictImage() async {
    var image = File(widget.imagePath);
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());

    setState(() {
      _busy = true;
      _image = image;
      _imageHeight = decodedImage.height.toDouble();
      _imageWidth = decodedImage.width.toDouble();
    });
    await poseNet(File(widget.imagePath));
  }

  Future poseNet(File image) async {
    int startTime = DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 1,
    );

    print(recognitions);

    setState(() {
      _recognitions = recognitions!;
    });
    int endTime = DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  List<Widget> renderKeypoints(Size screen) {
    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    for (var re in _recognitions) {
      var color = Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
          .withOpacity(1.0);
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      lists.addAll(list);
    }

    return lists;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      // TODO: switch to future builder
      child: _image == null
          ? const Text('No image selected.')
          : Image.file(_image!),
    ));

    stackChildren.addAll(renderKeypoints(size));

    if (_busy) {
      stackChildren.add(const Opacity(
        child: ModalBarrier(dismissible: false, color: Colors.grey),
        opacity: 0.3,
      ));
      stackChildren.add(const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('PoseNet'),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: predictImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.image),
      ),
    );
  }
}
