import 'package:intl/intl.dart';
import 'package:proto/main.dart';
import 'package:sqflite/sqflite.dart';

class Measurement {
  final int childId;
  final double height;
  final DateTime date;
  final int? id;
  final double? weight;

  Measurement(
      {required this.childId,
      required this.height,
      this.id,
      DateTime? inputDate,
      this.weight})
      : date = inputDate ?? DateTime.now();

  Measurement.fromMap(Map<String, dynamic> map)
      : id = map['measurement_id'],
        childId = map['child_id'],
        height = map['height'],
        date = DateTime.parse(map['date']),
        weight = map['weight'];

  Map<String, dynamic> toMap() {
    return {
      'measurement_id': id,
      'child_id': childId,
      'height': height,
      'weight': weight,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
  }
}

Future<void> insertMeasurement(Measurement measurement) async {
  await db.insert(
    'measurements',
    measurement.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}
