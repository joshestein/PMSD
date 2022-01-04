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

  Parent.fromMap(Map<String, dynamic> map)
      : idCardNo = map['id_card_number'],
        id = map['parent_id'],
        name = map['name'],
        number = map['number'],
        email = map['email'];

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

Future<List<String>> getAllParentsIds() async {
  final List<Map<String, dynamic>> maps =
      await db.query('parents', columns: ['id_card_number']);
  return List.generate(maps.length, (i) => maps[i]['id_card_number']);
}
