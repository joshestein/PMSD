import 'package:proto/main.dart';
import 'package:sqflite/sqflite.dart';

class Child {
  final int parentId;
  final String name;
  final String sex;
  final int? id;
  final String? ageInMonths;

  Child({
    required this.parentId,
    required this.name,
    this.sex = 'M',
    this.id,
    this.ageInMonths,
  });

  Child.fromMap(Map<String, dynamic> map)
      : parentId = map['parent_id'],
        id = map['child_id'],
        name = map['name'],
        sex = map['sex'],
        ageInMonths = map['age_in_months'];

  Map<String, dynamic> toMap() {
    return {
      'child_id': id,
      'parent_id': parentId,
      'sex': sex,
      'name': name,
      'age_in_months': ageInMonths,
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
