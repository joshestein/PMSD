import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';

final DynamicLibrary opencvLib = Platform.isAndroid
    ? DynamicLibrary.open('libopencv.so')
    : DynamicLibrary.process();

final int Function(int x, int y) opencvTest = opencvLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>('opencv_test')
    .asFunction();

class OpenCV {
  static const MethodChannel _channel = MethodChannel('opencv');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
