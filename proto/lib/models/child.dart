import 'package:sqflite/sqflite.dart';

import '../main.dart';

class Child {
  final int parentId;
  final int? id;
  final String? name;
  final int? ageInMonths;

  Child({
    required this.parentId,
    this.id,
    this.name,
    this.ageInMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      'child_id': id,
      'parent_id': parentId,
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
