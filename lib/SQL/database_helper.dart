import 'package:pos_system_legphel/models/Menu%20Model/menu_items_model_local_stg.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('MenuItems.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

//  SQFL Table
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT,
        price INTEGER,
        quantity INTEGER,
        description TEXT,
        menutype TEXT,
        availiability INTEGER NOT NULL CHECK (availiability IN (0,1)),
        image TEXT
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final db = await instance.database;
    Map<String, dynamic> productMap = product.toMap();
    return await db.insert('products', productMap);
  }

  Future<List<Product>> fetchProducts({int limit = 20, int offset = 0}) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      orderBy: 'name ASC',
      limit: limit,
      offset: offset,
    );

    return result.map((map) {
      Product product = Product.fromMap(map);
      return product;
    }).toList();
  }

  Future<int> getTotalProductsCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;

    if (product.id == null) {
      return 0;
    }

    final existingProduct = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (existingProduct.isEmpty) {
      return 0;
    }

    int result = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    return result;
  }

  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isCategoryUsed(String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'menutype = ?',
      whereArgs: [categoryId],
      limit: 1, // Only need to check if at least one product exists
    );
    return result.isNotEmpty; // Returns true if the category is used
  }

  Future<int> deleteAllProducts() async {
    final db = await instance.database;
    return await db
        .delete('products'); // Deletes all rows from the products table
  }
}
