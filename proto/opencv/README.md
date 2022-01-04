# OpenCV

This is a local flutter plugin to allow for native OpenCV code. Although not straightforward to setup, the resulting plugin allows for _any_ OpenCV function to be called on both Android and iOS.

Fundamentally, we use Dart's [Foreign Function Interface (FFI)](https://docs.flutter.dev/development/platform-integration/c-interop#compiled-dynamic-library) to allow calling native C code.

## Setup

These steps are mostly sourced from [Flutter Clutter's Edge Detection tutorial](https://www.flutterclutter.dev/flutter/tutorials/implementing-edge-detection-in-flutter/).

1. Follow the steps in the [flutter C interop guide](https://docs.flutter.dev/development/platform-integration/c-interop#compiled-dynamic-library) to generate a plugin, write native C code and use a CMakeLists.txt to compile the code.
1. Download and extract both Android and iOS [releases of OpenCV](https://opencv.org/releases/).
1. Copy the source files to our root directory:
   ```
   cp -r sdk/native/jni/include {plugin_root}/
   cp -r sdk/native/libs/* {plugin_root}/android/src/main/cmakeLibs/*
   ```
   Note how the destination directory for the dependent libs is _not_ `jniLibs/`. Attempting to do so will generate compile errors. See https://developer.android.com/studio/projects/gradle-external-native-builds#jniLibs for more info.
1. Copy the iOS library:
   ```
   cp -r opencv2.framework {plugin_root}/ios
   ```

You should now be able to write and bind to native C code! Any C/C++ code should be placed in the ios/Classes folder, since 'because CocoaPods doesn’t allow including sources above the podspec file, but Gradle allows you to point to the ios folder'.

Remember that any code you wish to run via dart needs to be marked `extern`.

Finally, to bind to dart functions (that can be called within your flutter app), you will need to lookup the exposed C functions. See `lib/opencv.dart` for how this was done.

## Usage

Since this is a local plugin, one needs to update the main `pubspec.yaml` with a relative path to the plugin. You can do this by using the `path` keyword when specifying the plugin dependency. See https://stackoverflow.com/a/51238421 for more info.

## Dependencies

This plugin depends on the [ffi package](https://pub.dev/packages/ffi). This allows (amongst other things) for conversion between Dart datatypes and C datatypes. For example, we have a Dart `String` parameter which we convert to a pointer to the first character in a char array using `toNativeUtf8`.
