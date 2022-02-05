import 'package:intl/intl.dart';
import 'package:proto/main.dart';
import 'package:proto/models/measurement.dart';
import 'package:sqflite/sqflite.dart';

class Child {
  int parentId;
  String name;
  String sex;
  DateTime dateOfBirth;
  int? id;

  Child({
    required this.parentId,
    required this.name,
    DateTime? inputDOB,
    this.sex = 'M',
    this.id,
  }) : dateOfBirth = inputDOB ?? DateTime.now();

  Child.fromMap(Map<String, dynamic> map)
      : parentId = map['parent_id'],
        id = map['child_id'],
        dateOfBirth = DateTime.parse(map['date_of_birth']),
        name = map['name'],
        sex = map['sex'];

  Future<List<Measurement>> get measurements async {
    final List<Map<String, dynamic>> measurements =
        await db.query('measurements', where: 'child_id = ?', whereArgs: [id]);
    return List.generate(
        measurements.length, (i) => Measurement.fromMap(measurements[i]));
  }

  Map<String, dynamic> toMap() {
    return {
      'child_id': id,
      'parent_id': parentId,
      'sex': sex,
      'name': name,
      'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth)
    };
  }
}

Future<void> insertChild(Child child) async {
  int id = await db.insert(
    'children',
    child.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  child.id ??= id;
}

Future<List<Child>> getChildrenForParent(int parentId) async {
  final List<Map<String, dynamic>> maps = await db.query(
    'children',
    where: 'parent_id = ?',
    whereArgs: [parentId],
  );
  return List.generate(maps.length, (i) {
    return Child.fromMap(maps[i]);
  });
}
