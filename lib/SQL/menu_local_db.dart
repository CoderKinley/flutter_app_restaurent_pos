import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MenuLocalDb {
  static final MenuLocalDb instance = MenuLocalDb._internal();
  // static final MenuLocalDb instance = MenuLocalDb._init();
  factory MenuLocalDb() => instance;
  MenuLocalDb._internal();

  static Database? _database;

  MenuLocalDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'menu.db');
    return await openDatabase(
      path,
      version: 3,
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
            updated_at TEXT
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
      },
    );
  }

  Future<void> insertMenuItem(MenuModel item) async {
    final db = await database;
    await db.insert(
      'menu',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
