import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart';

class Measurement {
  final int childId;
  final int height;
  final DateTime date;
  final int? id;
  final int? weight;

  Measurement(
      {required this.childId,
      required this.height,
      this.id,
      DateTime? inputDate,
      this.weight})
      : date = inputDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'child_id': childId,
      'height': height,
      'weight': weight,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }

  Future<void> insertMeasurement(Measurement measurement) async {
    await db.insert(
      'measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
