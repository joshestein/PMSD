import 'package:sqflite/sqflite.dart';

import '../main.dart';

class Child {
  final int id;
  final int parentId;
  final String? name;
  final int? ageInMonths;

  Child({
    required this.id,
    required this.parentId,
    this.name,
    this.ageInMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'age_in_months': ageInMonths,
    };
  }

  Future<void> insertChild(Child child) async {
    await db.insert(
      'children',
      child.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
