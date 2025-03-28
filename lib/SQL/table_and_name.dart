import 'package:pos_system_legphel/models/tables%20and%20names/customer_info_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CustomerInfoDatabaseHelper {
  static final CustomerInfoDatabaseHelper instance =
      CustomerInfoDatabaseHelper._init();
  static Database? _database;

  CustomerInfoDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('CustomerInfoDB.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customer_orders (
        orderId TEXT PRIMARY KEY,
        tableNumber TEXT,
        customerName TEXT,
        customerContact TEXT,
        orderDateTime TEXT,
        orderedItems TEXT
      )
    ''');
  }

  Future<int> insertCustomerOrder(CustomerInfoModel order) async {
    final db = await instance.database;
    return await db.insert('customer_orders', order.toMap());
  }

  Future<List<CustomerInfoModel>> fetchCustomerOrders() async {
    final db = await instance.database;
    final result =
        await db.query('customer_orders', orderBy: 'orderDateTime ASC');
    return result.map((map) => CustomerInfoModel.fromMap(map)).toList();
  }

  Future<int> updateCustomerOrder(CustomerInfoModel order) async {
    final db = await instance.database;
    return await db.update(
      'customer_orders',
      order.toMap(),
      where: 'orderId = ?',
      whereArgs: [order.orderId],
    );
  }

  Future<CustomerInfoModel?> fetchCustomerOrderById(String orderId) async {
    final db = await instance.database;
    final result = await db.query(
      'customer_orders',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );

    if (result.isNotEmpty) {
      return CustomerInfoModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> deleteCustomerOrder(String orderId) async {
    final db = await instance.database;
    return await db
        .delete('customer_orders', where: 'orderId = ?', whereArgs: [orderId]);
  }

  Future<int> updateCustomerOrderById(
      int orderId, CustomerInfoModel updatedOrder) async {
    final db = await database;
    return await db.update(
      'customer_orders',
      updatedOrder.toMap(),
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }
}
