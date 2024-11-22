import 'package:koda/database/database_item.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;

    _db = await initDatabase();
    return _db!;
  }

  Future<Database> initDatabase() async {
    final String databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "item.db");
    final database = openDatabase(databasePath, version: 1, onCreate: onCreate);
    return database;
  }

  Future<void> onCreate(Database db, int version) async {
    DatabaseItem dbItem = DatabaseItem();
    await dbItem.createTable(db);
  }
}
