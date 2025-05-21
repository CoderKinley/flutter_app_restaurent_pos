import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const String _showFetchButtonKey = 'show_fetch_button';
  static const String _showDatabaseManagementKey = 'show_database_management';
  static const String _branchIdKey = 'branch_id';

  static Future<bool> getShowFetchButton() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showFetchButtonKey) ?? false;
  }

  static Future<void> setShowFetchButton(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showFetchButtonKey, value);
  }

  static Future<bool> getShowDatabaseManagement() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showDatabaseManagementKey) ?? true;
  }

  static Future<void> setShowDatabaseManagement(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showDatabaseManagementKey, value);
  }

  static Future<String?> getBranchId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_branchIdKey);
  }

  static Future<void> setBranchId(String branchId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_branchIdKey, branchId);
  }
}
