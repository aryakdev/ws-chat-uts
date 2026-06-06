import 'package:shared_preferences/shared_preferences.dart';

Future<String?> storageGetString(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> storageSetString(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<void> storageRemove(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

Future<bool?> storageGetBool(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key);
}

Future<void> storageSetBool(String key, bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(key, value);
}