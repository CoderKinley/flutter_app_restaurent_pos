import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pos_system_legphel/models/Menu Model/allergic_item_model.dart';

class AllergicItemsDatabase {
  static final AllergicItemsDatabase instance = AllergicItemsDatabase._init();
  static Database? _database;

  AllergicItemsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('allergic_items.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE allergic_items (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> insert(AllergicItemModel item) async {
    final db = await instance.database;
    await db.insert(
      'allergic_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(AllergicItemModel item) async {
    final db = await instance.database;
    await db.update(
      'allergic_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await instance.database;
    await db.delete(
      'allergic_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<AllergicItemModel>> getAllItems() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('allergic_items');

    return List.generate(maps.length, (i) {
      return AllergicItemModel.fromMap(maps[i]);
    });
  }

  Future<AllergicItemModel?> getItem(String id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'allergic_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return AllergicItemModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
