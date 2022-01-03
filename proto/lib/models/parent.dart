import 'package:sqflite/sqflite.dart';

import '../main.dart';

class Parent {
  final String idCardNo;
  final int? id;
  final String? name;
  final String? number;
  final String? email;

  const Parent({
    required this.idCardNo,
    this.id,
    this.name,
    this.number,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_card_number': idCardNo,
      'parent_id': id,
      'name': name,
      'number': number,
      'email': email,
    };
  }
}

Future<int> insertParent(Parent parent) async {
  print(parent.id);
  int id = await db.insert(
    'parents',
    parent.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  print(await db.query('parents', where: 'parent_id = ?', whereArgs: [id]));
  return id;
}

Future<List<int>> getAllParentsIds() async {
  final List<Map<String, dynamic>> maps =
      await db.query('parents', columns: ['parent_id']);
  return List.generate(maps.length, (i) => maps[i]['parent_id']);
}
