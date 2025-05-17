import 'package:pos_system_legphel/SQL/menu_local_db.dart';
import 'package:pos_system_legphel/models/others/new_menu_model.dart';
import 'package:pos_system_legphel/data/menu_api_service.dart';
import 'package:pos_system_legphel/bloc/category_bloc/bloc/cetagory_bloc.dart';
import 'package:pos_system_legphel/bloc/sub_category_bloc/bloc/sub_category_bloc.dart';
import 'package:pos_system_legphel/models/others/category_model.dart';
import 'package:pos_system_legphel/models/others/sub_category_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuRepository {
  final MenuLocalDb localDb;
  final MenuApiService apiService;
  final CategoryBloc categoryBloc;
  final SubcategoryBloc subcategoryBloc;

  MenuRepository(
      this.localDb, this.apiService, this.categoryBloc, this.subcategoryBloc);

  Future<List<MenuModel>> getMenuItems() async {
    return await localDb.getMenuItems();
  }

  Future<bool> fetchAndUpdateMenuFromApi() async {
    try {
      // Fetch from API
      final apiItems = await apiService.fetchMenuItems();

      // Clear local database
      await localDb.clearDatabase();

      // Extract unique categories and subcategories
      final Set<String> uniqueCategories = {};
      final Map<String, Set<String>> categorySubcategories = {};

      for (var item in apiItems) {
        if (item.menuType?.isNotEmpty ?? false) {
          uniqueCategories.add(item.menuType!);

          if (item.subMenuType?.isNotEmpty ?? false) {
            if (!categorySubcategories.containsKey(item.menuType)) {
              categorySubcategories[item.menuType!] = {};
            }
            categorySubcategories[item.menuType!]!.add(item.subMenuType!);
          }
        }
      }

      // Clear existing categories and subcategories
      for (var category in await categoryBloc.state is CategoryLoaded
          ? (categoryBloc.state as CategoryLoaded).categories
          : []) {
        categoryBloc.add(DeleteCategory(category.categoryId));
      }

      // Insert categories and their subcategories
      for (var categoryName in uniqueCategories) {
        final category = CategoryModel(
          categoryId: const Uuid().v4(),
          categoryName: categoryName,
          status: 'active',
        );

        // Add category using bloc
        categoryBloc.add(AddCategory(category));

        // Add subcategories for this category
        if (categorySubcategories.containsKey(categoryName)) {
          for (var subcategoryName in categorySubcategories[categoryName]!) {
            final subcategory = SubcategoryModel(
              subcategoryId: const Uuid().v4(),
              subcategoryName: subcategoryName,
              categoryId: category.categoryId,
              status: 'active',
            );

            // Add subcategory using bloc
            subcategoryBloc.add(AddSubcategory(subcategorylist: subcategory));
          }
        }
      }

      // Insert all menu items
      for (var item in apiItems) {
        await localDb.insertMenuItem(item);
      }

      return true;
    } catch (e) {
      print('Error fetching from API: $e');
      return false;
    }
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
