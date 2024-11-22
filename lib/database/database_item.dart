import 'package:koda/database/database_service.dart';
import 'package:koda/models/item_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseItem {
  final String tableName = "item";
  final String columnId = "id";
  final String columnName = "name";
  final String columnWeight = "weight";
  final String columnDescription = "description";
  final DatabaseService databaseService = DatabaseService.instance;

  Future<void> createTable(Database db) async {
    await db.execute(
      "CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $columnName TEXT, $columnWeight REAL, $columnDescription TEXT)",
    );
  }

  Future<List<Item>> read() async {
    final db = await databaseService.database;
    final data = await db.query(tableName);

    List<Item> items = data.map((e) => Item.fromDatabase(e)).toList();
    return items;
  }

  Future<void> insert(Item item) async {
    final db = await databaseService.database;
    db.insert(tableName, item.toDatabase());
  }

  Future<void> update(Item item) async {
    final db = await databaseService.database;
    db.update(
      tableName,
      item.toDatabase(),
      where: "id = ?",
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await databaseService.database;
    db.delete(tableName, where: "id = ?", whereArgs: [id]);
  }
}
