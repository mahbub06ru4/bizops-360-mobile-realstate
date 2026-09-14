import 'package:get_storage/get_storage.dart';

/// Fast local key–value box for per-device preferences and small caches.
/// Never secrets (see [SecureStore]) and never a source of truth.
class KvStore {
  KvStore([GetStorage? box]) : _box = box ?? GetStorage();

  final GetStorage _box;

  static const String _localeKey = 'locale'; // 'en' | 'bn'
  static const String _themeKey = 'theme_mode'; // 'light' | 'dark' | 'system'
  static const String _lastEmailKey = 'last_email';

  static Future<void> ensureInitialised() => GetStorage.init();

  String? get localeCode => _box.read<String>(_localeKey);
  set localeCode(String? code) => _writeOrRemove(_localeKey, code);

  String get themeMode => _box.read<String>(_themeKey) ?? 'system';
  set themeMode(String value) => _box.write(_themeKey, value);

  String? get lastEmail => _box.read<String>(_lastEmailKey);
  set lastEmail(String? email) => _writeOrRemove(_lastEmailKey, email);

  Future<void> clearSession() async {
    await _box.remove(_lastEmailKey);
  }

  void _writeOrRemove(String key, String? value) {
    if (value == null || value.isEmpty) {
      _box.remove(key);
    } else {
      _box.write(key, value);
    }
  }
}
