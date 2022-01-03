import 'package:flutter/material.dart';
import 'package:proto/db_helper.dart';
import 'package:proto/image_picker.dart';
import 'package:sqflite/sqflite.dart';

late Database db;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  db = await DatabaseHelper().getDb();

  runApp(MaterialApp(
    theme: ThemeData.dark(),
    home: const ImagePickerScreen(),
  ));
}
