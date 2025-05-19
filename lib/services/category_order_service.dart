import 'package:shared_preferences/shared_preferences.dart';

class CategoryOrderService {
  static const String _orderKey = 'category_order';

  static Future<List<String>> getCategoryOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_orderKey) ?? [];
  }

  static Future<void> saveCategoryOrder(List<String> categoryIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_orderKey, categoryIds);
  }
}
