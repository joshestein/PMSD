import 'package:flutter/material.dart';
import 'package:proto/image_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: const ImagePickerScreen(),
    // home: const ImagePreview(),
  ));
}
