import 'package:proto/main.dart';
import 'package:sqflite/sqflite.dart';

class Parent {
  String idCardNo;
  int? id;
  String? name;
  String? number;
  String? email;

  Parent({
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
  int id = await db.insert(
    'parents',
    parent.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  return id;
}

Future<List<Parent>> getAllParents() async {
  final List<Map<String, dynamic>> maps = await db.query('parents');
  return List.generate(maps.length, (i) => Parent.fromMap(maps[i]));
}

/// Given an [idCardNo] number, returns the corresponding primary key ID
Future<int> getParentId(String idCardNo) async {
  final List<Map<String, dynamic>> maps = await db
      .query('parents', where: 'id_card_number = ?', whereArgs: [idCardNo]);
  return maps.first['parent_id'];
}
