import 'package:pos_system_legphel/models/others/sub_category_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:pos_system_legphel/models/others/category_model.dart';

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

    return await openDatabase(
      path,
      version: 2, // Increment version if you update the schema
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // Handle schema updates
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        categoryId TEXT PRIMARY KEY,
        categoryName TEXT,
        status TEXT,
        sortOrder INTEGER
      )
    ''');

    // Create subcategories table
    await db.execute('''
      CREATE TABLE subcategories (
        subcategoryId TEXT PRIMARY KEY,
        subcategoryName TEXT,
        categoryId TEXT,
        status TEXT,
        sortOrder INTEGER,
        FOREIGN KEY (categoryId) REFERENCES categories (categoryId)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the subcategories table for version 2
      await db.execute('''
        CREATE TABLE subcategories (
          subcategoryId TEXT PRIMARY KEY,
          subcategoryName TEXT,
          categoryId TEXT,
          status TEXT,
          sortOrder INTEGER,
          FOREIGN KEY (categoryId) REFERENCES categories (categoryId)
        )
      ''');
    }
  }

  // ==================== Category CRUD Operations ====================

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
    return await db.delete(
      'categories',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
  }

  // ==================== Subcategory CRUD Operations ====================
  // Fetch all subcategories (New function)
  Future<List<SubcategoryModel>> fetchAllSubcategories() async {
    final db = await instance.database;
    final result = await db.query(
      'subcategories',
      orderBy: 'sortOrder ASC',
    );

    return result.map((map) => SubcategoryModel.fromMap(map)).toList();
  }

  // Insert a new subcategory
  Future<int> insertSubcategory(SubcategoryModel subcategory) async {
    final db = await instance.database;
    return await db.insert('subcategories', subcategory.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Fetch all subcategories for a specific category
  Future<List<SubcategoryModel>> fetchSubcategoriesByCategoryId(
      String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'subcategories',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'sortOrder ASC',
    );

    return result.map((map) => SubcategoryModel.fromMap(map)).toList();
  }

  // Update a subcategory
  Future<int> updateSubcategory(SubcategoryModel subcategory) async {
    final db = await instance.database;
    return await db.update(
      'subcategories',
      subcategory.toMap(),
      where: 'subcategoryId = ?',
      whereArgs: [subcategory.subcategoryId],
    );
  }

  // Delete a subcategory
  Future<int> deleteSubcategory(String subcategoryId) async {
    final db = await instance.database;
    return await db.delete(
      'subcategories',
      where: 'subcategoryId = ?',
      whereArgs: [subcategoryId],
    );
  }

  // Clear all categories
  Future<int> clearCategories() async {
    final db = await instance.database;
    return await db.delete('categories');
  }

  // Clear all subcategories
  Future<int> clearSubcategories() async {
    final db = await instance.database;
    return await db.delete('subcategories');
  }

  // Close the database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
