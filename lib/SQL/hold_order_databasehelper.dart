import 'package:pos_system_legphel/models/Menu%20Model/hold_order_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HoldOrderDatabaseHelper {
  static final HoldOrderDatabaseHelper instance =
      HoldOrderDatabaseHelper._init();
  static Database? _database;

  HoldOrderDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('HoldOrders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // SQFL Table for Hold Orders
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hold_orders (
        holdOrderId TEXT PRIMARY KEY,
        tableNumber TEXT,
        customerName TEXT,
        orderDateTime TEXT,
        menuItems TEXT
      )
    ''');
  }

  // Insert a Hold Order
  Future<int> insertHoldOrder(HoldOrderModel holdOrder) async {
    final db = await instance.database;
    Map<String, dynamic> holdOrderMap = holdOrder.toMap();
    return await db.insert('hold_orders', holdOrderMap);
  }

  // Fetch all Hold Orders
  Future<List<HoldOrderModel>> fetchHoldOrders() async {
    final db = await instance.database;
    final result = await db.query('hold_orders', orderBy: 'orderDateTime ASC');

    return result.map((map) {
      return HoldOrderModel.fromMap(map);
    }).toList();
  }

  // Update a Hold Order
  Future<int> updateHoldOrder(HoldOrderModel holdOrder) async {
    final db = await instance.database;

    if (holdOrder.holdOrderId.isEmpty) {
      return 0;
    }

    final existingOrder = await db.query(
      'hold_orders',
      where: 'holdOrderId = ?',
      whereArgs: [holdOrder.holdOrderId],
    );

    if (existingOrder.isEmpty) {
      return 0;
    }

    int result = await db.update(
      'hold_orders',
      holdOrder.toMap(),
      where: 'holdOrderId = ?',
      whereArgs: [holdOrder.holdOrderId],
    );
    return result;
  }

  // Delete a Hold Order
  Future<int> deleteHoldOrder(String holdOrderId) async {
    final db = await instance.database;
    return await db.delete('hold_orders',
        where: 'holdOrderId = ?', whereArgs: [holdOrderId]);
  }
}
