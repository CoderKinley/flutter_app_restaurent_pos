import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pos_system_legphel/models/destination_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'pos_system.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createDestinationsTable(db);
    // Add other table creation methods here
  }

  static const String _destinationTable = 'destinations';
  static const String _destinationId = 'id';
  static const String _destinationName = 'name';

  Future<void> _createDestinationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_destinationTable(
        $_destinationId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_destinationName TEXT NOT NULL
      )
    ''');
  }

  // Destination CRUD operations
  Future<int> insertDestination(Destination destination) async {
    final db = await database;
    return await db.insert(_destinationTable, destination.toMap());
  }

  Future<List<Destination>> getDestinations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_destinationTable);
    return List.generate(maps.length, (i) => Destination.fromMap(maps[i]));
  }

  Future<int> updateDestination(Destination destination) async {
    final db = await database;
    return await db.update(
      _destinationTable,
      destination.toMap(),
      where: '$_destinationId = ?',
      whereArgs: [destination.id],
    );
  }

  Future<int> deleteDestination(int id) async {
    final db = await database;
    return await db.delete(
      _destinationTable,
      where: '$_destinationId = ?',
      whereArgs: [id],
    );
  }
}
