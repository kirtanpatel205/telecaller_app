import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  const Storage._();

  static final GetStorage _storage = GetStorage();

  static GetStorage get storage => _storage;

  static Future<void> saveValue(String key, dynamic value) =>
      _storage.write(key, value);

  static T? getValue<T>(String key) => _storage.read<T>(key);

  static bool hasData(String key) => _storage.hasData(key);

  static Future<void> removeValue(String key) => _storage.remove(key);

  static Future<void> clearStorage() => _storage.erase();
  static Future<void> saveToSharedPrefs(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }

  static Future<T?> getFromSharedPrefs<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (T == String) return prefs.getString(key) as T?;
      if (T == bool) return prefs.getBool(key) as T?;
      if (T == int) return prefs.getInt(key) as T?;
      if (T == double) return prefs.getDouble(key) as T?;
      return prefs.get(key) as T?;
    } catch (e) {
      return null;
    }
  }

  // Specialized Token management for cross-isolate reliability
  static Future<void> saveToken(String token) async {
    await saveValue('auth_token', token); // Still save to GetStorage for UI
    await saveToSharedPrefs('auth_token', token); // Save to SharedPrefs for BG
  }

  static Future<String?> getToken() async {
    // 1. Try SharedPrefs (most reliable for background)
    String? token = await getFromSharedPrefs<String>('auth_token');
    
    // 2. Fallback to GetStorage (may work in foreground)
    if (token == null || token.isEmpty) {
      token = getValue<String>('auth_token');
    }
    
    return token;
  }

  // Cross-isolate Event De-duplication
  static Future<bool> isEventProcessed(String type, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // IMPORTANT: Force-load latest data from disk
    // Use a composite key: eventType_sessionId
    return prefs.getBool('event_${type}_$sessionId') ?? false;
  }

  static Future<void> markEventProcessed(String type, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('event_${type}_$sessionId', true);
  }

  // Active Session Persistence
  static Future<void> saveActiveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_call_session_id', sessionId);
  }

  static Future<String?> getActiveSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getString('active_call_session_id');
  }

  static Future<void> clearActiveSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_call_session_id');
  }
}
