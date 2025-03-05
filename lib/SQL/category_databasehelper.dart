import 'package:pos_system_legphel/models/category_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryDatabaseHelper {
  static final CategoryDatabaseHelper instance = CategoryDatabaseHelper._init();
  static Database? _database;

  CategoryDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('Categories.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        categoryId TEXT PRIMARY KEY,
        categoryName TEXT,
        status TEXT,
        sortOrder INTEGER
      )
    ''');
  }

  // Insert a new category
  Future<int> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch all categories
  Future<List<CategoryModel>> fetchCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'sortOrder ASC');

    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  // Update a category
  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;

    return await db.update(
      'categories',
      category.toMap(),
      where: 'categoryId = ?',
      whereArgs: [category.categoryId],
    );
  }

  // Delete a category
  Future<int> deleteCategory(String categoryId) async {
    final db = await instance.database;
    return await db
        .delete('categories', where: 'categoryId = ?', whereArgs: [categoryId]);
  }
}
