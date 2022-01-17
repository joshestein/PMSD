import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:proto/image_preview.dart';
import 'package:proto/models/child.dart';

/// Fetches an image from storage and displays it on the screen.
/// Further, calculates the rendered image width and height.
class ImageLoader extends StatefulWidget {
  final String imagePath;
  final Child child;

  const ImageLoader({Key? key, required this.imagePath, required this.child})
      : super(key: key);

  @override
  _ImageLoaderState createState() => _ImageLoaderState();
}

class _ImageLoaderState extends State<ImageLoader> {
  GlobalKey imageKey = GlobalKey();

  Image _getImage() {
    // Why network for web?
    // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
    return kIsWeb
        ? Image.network(
            widget.imagePath,
            key: imageKey,
          )
        : Image.file(
            File(widget.imagePath),
            fit: BoxFit.contain,
            key: imageKey,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        const Center(child: Text('Loading...')),
        _getImage(),
        FutureBuilder<ui.Image>(
            future: loadUiImage(widget.imagePath),
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              return _getRenderedSize(snapshot, context);
            }),
      ],
    );
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    final Uint8List data = await File(imageAssetPath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image image) {
      return completer.complete(image);
    });
    return completer.future;
  }

  Widget _getRenderedSize(
      AsyncSnapshot<ui.Image> snapshot, BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) return Container();
    if (snapshot.hasError) return Text('Error: ${snapshot.error}');

    final keyContext = imageKey.currentContext;

    if (keyContext == null) {
      return Container();
    }

    final box = keyContext.findRenderObject() as RenderBox;
    if (box.hasSize) {
      Size originalSize = Size(
          snapshot.data!.width.toDouble(), snapshot.data!.height.toDouble());
      Size renderedSize = Size(box.size.width, box.size.height);

      return ImagePreview(
          imagePath: widget.imagePath,
          child: widget.child,
          originalSize: originalSize,
          renderedSize: renderedSize);
    } else {
      return Text('Loading...',
          style: Theme.of(context).primaryTextTheme.headline5);
    }
  }
}
