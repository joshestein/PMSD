import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ffi/ffi.dart';

final DynamicLibrary opencvLib = Platform.isAndroid
    ? DynamicLibrary.open('libopencv.so')
    : DynamicLibrary.process();

final double Function(Pointer<Utf8>) pixelsPerMM = opencvLib
    .lookup<NativeFunction<Double Function(Pointer<Utf8>)>>('get_pixels_per_mm')
    .asFunction();

class OpenCV {
  static const MethodChannel _channel = MethodChannel('opencv');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<double> getPixelsPerMM(String path) async {
    double result = pixelsPerMM(path.toNativeUtf8());
    return result;
  }

  static double getFastPixelsPerMM(String path) {
    double result = pixelsPerMM(path.toNativeUtf8());
    return result;
  }
}
