import 'package:pos_system_legphel/models/Menu%20Model/proceed_order_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProceedOrderDatabaseHelper {
  static final ProceedOrderDatabaseHelper instance =
      ProceedOrderDatabaseHelper._init();
  static Database? _database;

  ProceedOrderDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    // to retriever the old data from the data you can use this
    // but might need to change the model as it has lesser data
    // _database = await _initDB('ProceedOrdersFromAPINew.db');
    _database = await _initDB('ProceedOrderDataBase01.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // SQLite Table for Proceed Orders
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE proceed_orders (
        holdOrderId TEXT PRIMARY KEY,
        tableNumber TEXT,
        customerName TEXT,
        phoneNumber TEXT,
        orderNumber TEXT, 
        restaurantBranchName TEXT,
        orderDateTime TEXT,
        menuItems TEXT,
        totalAmount REAL
      )
    ''');
  }

  // Insert a Proceed Order
  Future<int> insertProceedOrder(ProceedOrderModel proceedOrder) async {
    final db = await instance.database;
    Map<String, dynamic> proceedOrderMap = proceedOrder.toMap();
    return await db.insert('proceed_orders', proceedOrderMap);
  }

  // Fetch all Proceed Orders
  Future<List<ProceedOrderModel>> fetchProceedOrders() async {
    final db = await instance.database;
    final result =
        await db.query('proceed_orders', orderBy: 'orderDateTime ASC');

    return result.map((map) {
      return ProceedOrderModel.fromMap(map);
    }).toList();
  }

  // Update a Proceed Order
  Future<int> updateProceedOrder(ProceedOrderModel proceedOrder) async {
    final db = await instance.database;

    if (proceedOrder.holdOrderId.isEmpty) {
      return 0;
    }

    final existingOrder = await db.query(
      'proceed_orders',
      where: 'holdOrderId = ?',
      whereArgs: [proceedOrder.holdOrderId],
    );

    if (existingOrder.isEmpty) {
      return 0;
    }

    int result = await db.update(
      'proceed_orders',
      proceedOrder.toMap(),
      where: 'holdOrderId = ?',
      whereArgs: [proceedOrder.holdOrderId],
    );
    return result;
  }

  // Delete a Proceed Order
  Future<int> deleteProceedOrder(String holdOrderId) async {
    final db = await instance.database;
    return await db.delete('proceed_orders',
        where: 'holdOrderId = ?', whereArgs: [holdOrderId]);
  }
}
