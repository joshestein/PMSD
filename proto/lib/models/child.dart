import 'package:intl/intl.dart';
import 'package:proto/main.dart';
import 'package:sqflite/sqflite.dart';

class Child {
  final int parentId;
  final String name;
  final String sex;
  final DateTime dateOfBirth;
  final int? id;

  Child({
    required this.parentId,
    required this.name,
    DateTime? dateOfBirth,
    this.sex = 'M',
    this.id,
  }) : this.dateOfBirth = dateOfBirth ?? DateTime.now();

  Child.fromMap(Map<String, dynamic> map)
      : parentId = map['parent_id'],
        id = map['child_id'],
        dateOfBirth = DateTime.parse(map['date_of_birth']),
        name = map['name'],
        sex = map['sex'];

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
  print(await db.query('children', where: 'child_id = ?', whereArgs: [id]));
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
