import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafePreferenceReads {
  static String? string(SharedPreferences prefs, String key) {
    try {
      return prefs.getString(key);
    } catch (error) {
      _logTypeMismatch(key, error);
      return null;
    }
  }

  static int? integer(SharedPreferences prefs, String key) {
    try {
      return prefs.getInt(key);
    } catch (error) {
      _logTypeMismatch(key, error);
      return null;
    }
  }

  static double? decimal(SharedPreferences prefs, String key) {
    try {
      return prefs.getDouble(key);
    } catch (error) {
      _logTypeMismatch(key, error);
      return null;
    }
  }

  static bool? boolean(SharedPreferences prefs, String key) {
    try {
      return prefs.getBool(key);
    } catch (error) {
      _logTypeMismatch(key, error);
      return null;
    }
  }

  static List<String>? stringList(SharedPreferences prefs, String key) {
    try {
      return prefs.getStringList(key);
    } catch (error) {
      _logTypeMismatch(key, error);
      return null;
    }
  }

  static void _logTypeMismatch(String key, Object error) {
    debugPrint('[DB] Ignoring unreadable preference "$key": $error');
  }
}
