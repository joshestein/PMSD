import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:proto/magnifier/image_preview.dart';

class ImagePickerScreen extends StatefulWidget {
  const ImagePickerScreen({Key? key}) : super(key: key);

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  List<XFile>? _imageFileList;

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : [value];
  }

  dynamic _pickImageError;
  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    if (isMultiImage) {
      try {
        final pickedFileList = await _picker.pickMultiImage();
        setState(() {
          _imageFileList = pickedFileList;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    } else {
      try {
        final pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 100,
        );
        setState(() {
          _imageFile = pickedFile;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
      return ImagePreview(imagePath: _imageFileList![0].path);
      // return ListView.builder(
      //   key: UniqueKey(),
      //   itemBuilder: (context, index) {
      //     return ImagePreview(imagePath: _imageFileList![index].path);
      //   },
      //   itemCount: _imageFileList!.length,
      //   // Ensure there is no conflicting gesture detection between the ListView
      //   // and the GestureDetector of the TouchBubbles.
      //   physics: const NeverScrollableScrollPhysics(),
      // );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
        _imageFileList = response.files;
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuhle'),
      ),
      body: Center(
        child: !kIsWeb && defaultTargetPlatform == TargetPlatform.android
            ? FutureBuilder<void>(
                future: retrieveLostData(),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Text(
                        'You have not yet picked an image.',
                        textAlign: TextAlign.center,
                      );
                    case ConnectionState.done:
                      return _previewImages();
                    default:
                      if (snapshot.hasError) {
                        return Text(
                          'Pick image/video error: ${snapshot.error}}',
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return const Text(
                          'You have not yet picked an image.',
                          textAlign: TextAlign.center,
                        );
                      }
                  }
                },
              )
            : _previewImages(),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Semantics(
            label: 'image_picker_from_gallery',
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.gallery, context: context);
              },
              heroTag: 'image0',
              tooltip: 'Pick Image from gallery',
              child: const Icon(Icons.photo),
            ),
          ),
          // TODO: allow processing of multiple images
          // Padding(
          //   padding: const EdgeInsets.only(top: 16.0),
          //   child: FloatingActionButton(
          //     onPressed: () {
          //       _onImageButtonPressed(
          //         ImageSource.gallery,
          //         context: context,
          //         isMultiImage: true,
          //       );
          //     },
          //     heroTag: 'image1',
          //     tooltip: 'Pick Multiple Image from gallery',
          //     child: const Icon(Icons.photo_library),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _onImageButtonPressed(ImageSource.camera, context: context);
              },
              heroTag: 'image2',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }
}
