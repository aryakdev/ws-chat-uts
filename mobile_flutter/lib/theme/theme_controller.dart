import 'package:flutter/material.dart';
import 'package:mobile_flutter/services/storage_io.dart' if (dart.library.html) 'package:mobile_flutter/services/storage_web.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  static Future<void> init() async {
    final isDark = await storageGetBool('isDark') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => themeNotifier.value == ThemeMode.dark;

  static Future<void> toggle() async {
    final nowDark = themeNotifier.value == ThemeMode.dark;
    themeNotifier.value = nowDark ? ThemeMode.light : ThemeMode.dark;
    await storageSetBool('isDark', !nowDark);
  }

  static Future<void> setDark(bool dark) async {
    themeNotifier.value = dark ? ThemeMode.dark : ThemeMode.light;
    await storageSetBool('isDark', dark);
  }
}