import 'dart:html' as html;

Future<String?> storageGetString(String key) async {
  return html.window.sessionStorage[key];
}

Future<void> storageSetString(String key, String value) async {
  html.window.sessionStorage[key] = value;
}

Future<void> storageRemove(String key) async {
  html.window.sessionStorage.remove(key);
}

Future<bool?> storageGetBool(String key) async {
  final val = html.window.sessionStorage[key];
  if (val == null) return null;
  return val == 'true';
}
Future<void> storageSetBool(String key, bool value) async =>
    html.window.sessionStorage[key] = value.toString();
