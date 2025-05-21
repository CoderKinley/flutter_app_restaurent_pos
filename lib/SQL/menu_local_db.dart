import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MenuLocalDb {
  // Proper singleton implementation
  static final MenuLocalDb instance = MenuLocalDb._init();

  // Private constructor
  MenuLocalDb._init();

  // Factory constructor redirects to singleton instance
  factory MenuLocalDb() => instance;

  // Database instance
  static Database? _database;

  // Database getter with lazy initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // for Main and town banch name newMenu.db
    // for kharpandi and hotel main menu.db
    String path = join(await getDatabasesPath(), 'newMenu.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE menu (
            menu_id TEXT PRIMARY KEY,
            menu_name TEXT NOT NULL,
            menu_type TEXT,
            sub_menu_type TEXT,
            price REAL NOT NULL,
            description TEXT,
            availability INTEGER NOT NULL CHECK (availability IN (0,1)),
            dish_image TEXT,
            uuid TEXT,
            created_at TEXT,
            updated_at TEXT,
            item_destination TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          List<Map<String, dynamic>> columns =
              await db.rawQuery("PRAGMA table_info(menu)");
          bool columnExists = columns.any((column) => column['name'] == 'uuid');

          if (!columnExists) {
            await db.execute("ALTER TABLE menu ADD COLUMN uuid TEXT");
          }
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE menu ADD COLUMN created_at TEXT");
          await db.execute("ALTER TABLE menu ADD COLUMN updated_at TEXT");
        }
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE menu ADD COLUMN item_destination TEXT");
        }
      },
    );
  }

  Future<bool> insertMenuItem(MenuModel item) async {
    try {
      final db = await database;

      // Validate required fields
      if (item.menuId.isEmpty ||
          item.menuName.isEmpty ||
          item.price.isEmpty ||
          double.tryParse(item.price) == null ||
          double.parse(item.price) <= 0) {
        print('Validation failed for menu item:');
        print('- menuId: ${item.menuId}');
        print('- menuName: ${item.menuName}');
        print('- price: ${item.price}');
        return false;
      }

      // Check if item already exists
      final existingItem = await getMenuItemById(item.menuId);
      if (existingItem != null) {
        print('Item with ID ${item.menuId} already exists, updating instead');
        await updateMenuItem(item);
        return true;
      }

      print('Inserting new menu item into database: ${item.toJson()}');
      // Insert new item
      await db.insert(
        'menu',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Successfully inserted menu item');
      return true;
    } catch (e, stackTrace) {
      print('Error inserting menu item: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<List<MenuModel>> getMenuItems() async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query('menu');
    return maps.map((map) => MenuModel.fromJson(map)).toList();
  }

  Future<MenuModel?> getMenuItemById(String menuId) async {
    final db = await database;
    List<Map<String, dynamic>> maps =
        await db.query('menu', where: 'menu_id = ?', whereArgs: [menuId]);

    if (maps.isNotEmpty) {
      return MenuModel.fromJson(maps.first);
    }
    return null;
  }

  Future<void> updateMenuItem(MenuModel item) async {
    final db = await database;
    await db.update(
      'menu',
      item.toJson(),
      where: 'menu_id = ?',
      whereArgs: [item.menuId],
    );
  }

  Future<void> deleteMenuItem(String menuId) async {
    final db = await database;
    await db.delete('menu', where: 'menu_id = ?', whereArgs: [menuId]);
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('menu');
  }
}
