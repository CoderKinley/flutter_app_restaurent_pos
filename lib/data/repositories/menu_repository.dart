import 'package:pos_system_legphel/SQL/menu_local_db.dart';
import 'package:pos_system_legphel/data/menu_api_service.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';

class MenuRepository {
  final MenuApiService apiService;
  final MenuLocalDb localDb;

  MenuRepository(this.apiService, this.localDb);

  Future<void> syncMenuItems() async {
    List<MenuModel> apiData = await apiService.fetchMenuItems();
    List<MenuModel> localData = await localDb.getMenuItems();

    Set<String> localIds = localData.map((item) => item.menuId).toSet();

    for (var item in apiData) {
      if (!localIds.contains(item.menuId)) {
        await localDb.insertMenuItem(item);
      }
    }
  }

  Future<List<MenuModel>> getMenuItems() async {
    return await localDb.getMenuItems();
  }

  Future<bool> addMenuItem(MenuModel menuItem) async {
    bool isAddedToApi = await apiService.addMenuItem(menuItem);
    if (isAddedToApi) {
      await localDb.insertMenuItem(menuItem);
    }
    return isAddedToApi;
  }

  Future<MenuModel?> getMenuItemById(String menuId) async {
    return await localDb.getMenuItemById(menuId);
  }

  Future<bool> updateMenuItem(MenuModel menuItem) async {
    bool isUpdatedInApi = await apiService.updateMenuItem(menuItem);
    if (isUpdatedInApi) {
      await localDb.updateMenuItem(menuItem);
    }
    return isUpdatedInApi;
  }

  Future<bool> deleteMenuItem(String menuId) async {
    bool isDeletedFromApi = await apiService.deleteMenuItem(menuId);
    if (isDeletedFromApi) {
      await localDb.deleteMenuItem(menuId);
    }
    return isDeletedFromApi;
  }
}
