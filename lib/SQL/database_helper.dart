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

  Future<List<Product>> fetchProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'name ASC');

    return result.map((map) {
      Product product = Product.fromMap(map);
      return product;
    }).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;

    // print("Updating product with ID: ${product.id}");

    if (product.id == null) {
      // print("Error: Product ID is NULL before update!");
      return 0;
    }

    // Check if the product exists before updating
    final existingProduct = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (existingProduct.isEmpty) {
      // print( "Error: Product with ID ${product.id} does not exist in the database!");
      return 0;
    }

    // print("Updating product: ID=${product.id}, Name=${product.name}");

    int result = await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
    // print("Update result: $result");
    return result;
  }

  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
