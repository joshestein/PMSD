import 'package:sqflite/sqflite.dart';

import '../main.dart';

class Parent {
  final String idCardNo;
  final int? id;
  final String? name;
  final int? number;
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
      'id': id,
      'name': name,
      'number': number,
      'email': email,
    };
  }

  Future<void> insertParent(Parent parent) async {
    await db.insert(
      'parents',
      parent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
