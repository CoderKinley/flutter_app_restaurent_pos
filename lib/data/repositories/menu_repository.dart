import 'package:pos_system_legphel/SQL/menu_local_db.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';

class MenuRepository {
  final MenuLocalDb localDb;

  MenuRepository(this.localDb);

  Future<List<MenuModel>> getMenuItems() async {
    return await localDb.getMenuItems();
  }

  Future<bool> addMenuItem(MenuModel menuItem) async {
    try {
      // Validate menu item
      if (menuItem.menuId.isEmpty ||
          menuItem.menuName.isEmpty ||
          menuItem.price.isEmpty) {
        print('Invalid menu item data: ${menuItem.toJson()}');
        return false;
      }

      // Try to parse price to ensure it's valid
      if (double.tryParse(menuItem.price) == null) {
        print('Invalid price format: ${menuItem.price}');
        return false;
      }

      print('Attempting to add menu item: ${menuItem.toJson()}');
      final result = await localDb.insertMenuItem(menuItem);
      print('Add menu item result: $result');
      return result;
    } catch (e, stackTrace) {
      print('Error in repository while adding menu item: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<MenuModel?> getMenuItemById(String menuId) async {
    return await localDb.getMenuItemById(menuId);
  }

  Future<bool> updateMenuItem(MenuModel menuItem) async {
    await localDb.updateMenuItem(menuItem);
    return true;
  }

  Future<bool> deleteMenuItem(String menuId) async {
    await localDb.deleteMenuItem(menuId);
    return true;
  }
}
