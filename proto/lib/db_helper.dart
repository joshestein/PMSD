import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database>? _db;

  Future<Database> getDb() {
    _db ??= _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'proto.db'),
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      version: 1,
    );
    return db;
  }

  _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  _onCreate(Database db, int version) async {
    // TODO: Fixed length ID number?
    await db.execute('''
      CREATE TABLE IF NOT EXISTS parents (
        parent_id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_card_number TEXT NOT NULL,
        name TEXT,
        number TEXT,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS children (
        child_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sex TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        parent_id INTEGER,

        FOREIGN KEY(parent_id) REFERENCES parents(parent_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS measurements (
        measurement_id INTEGER PRIMARY KEY AUTOINCREMENT,
        height REAL,
        weight REAL,
        date TEXT NOT NULL,
        child_id INTEGER,

        FOREIGN KEY(child_id) REFERENCES children(child_id)
      )
    ''');
  }

  Future close() async {
    final db = await getDb();
    db.close();
  }
}
