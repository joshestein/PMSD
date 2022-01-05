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

Future<List<Measurement>> getMeasurementsForChild(int childId) async {
  final List<Map<String, dynamic>> measurements = await db
      .query('measurements', where: 'child_id = ?', whereArgs: [childId]);
  return List.generate(
      measurements.length, (i) => Measurement.fromMap(measurements[i]));
}

Future<void> insertMeasurement(Measurement measurement) async {
  int id = await db.insert(
    'measurements',
    measurement.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  print(await db
      .query('measurements', where: 'measurement_id = ?', whereArgs: [id]));
}
