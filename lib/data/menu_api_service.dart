import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pos_system_legphel/models/others/new_menu_model.dart';

class MenuApiService {
  static const String apiUrl = "http://119.2.105.142:3800/api/menu";

  /// Fetch all menu items (GET)
  Future<List<MenuModel>> fetchMenuItems() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => MenuModel.fromJson(item)).toList();
    } else {
      throw Exception("Failed to fetch menu items");
    }
  }

  /// Add a new menu item (POST)
  Future<bool> addMenuItem(MenuModel menuItem) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(menuItem.toJson()),
    );

    return response.statusCode == 201;
  }

  Future<MenuModel?> fetchMenuItemById(int menuId) async {
    final response = await http.get(Uri.parse("$apiUrl/$menuId"));

    if (response.statusCode == 200) {
      return MenuModel.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> updateMenuItem(MenuModel menuItem) async {
    final response = await http.put(
      Uri.parse("$apiUrl/${menuItem.menuId}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(menuItem.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteMenuItem(String menuId) async {
    final response = await http.delete(Uri.parse("$apiUrl/$menuId"));

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
