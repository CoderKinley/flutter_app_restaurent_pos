import 'package:pos_system_legphel/models/others/table_no_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class TableDatabaseHelper {
  static final TableDatabaseHelper instance = TableDatabaseHelper._init();
  static Database? _database;

  TableDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('Tables.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tables (
        tableNumber TEXT PRIMARY KEY,
        tableName TEXT
      )
    ''');
  }

  Future<int> insertTable(TableNoModel table) async {
    final db = await instance.database;
    return await db.insert('tables', table.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<TableNoModel>> fetchTables() async {
    final db = await instance.database;
    final result = await db.query('tables', orderBy: 'tableNumber ASC');

    return result.map((map) => TableNoModel.fromMap(map)).toList();
  }

  Future<int> updateTable(TableNoModel table) async {
    final db = await instance.database;

    return await db.update(
      'tables',
      table.toMap(),
      where: 'tableNumber = ?',
      whereArgs: [table.tableNumber],
    );
  }

  Future<int> deleteTable(String tableNumber) async {
    final db = await instance.database;
    return await db
        .delete('tables', where: 'tableNumber = ?', whereArgs: [tableNumber]);
  }
}
