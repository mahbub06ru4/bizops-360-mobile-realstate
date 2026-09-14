import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/localization/app_translations.dart';
import '../../core/storage/kv_store.dart';

/// Per-device preferences: theme mode and language. Persisted to [KvStore] and
/// applied to the running [GetMaterialApp] immediately.
class SettingsController extends GetxController {
  SettingsController(this._store);

  final KvStore _store;

  late final Rx<ThemeMode> themeMode = _readThemeMode().obs;
  late final Rx<Locale> locale =
      (AppTranslations.fromCode(_store.localeCode) ?? _deviceLocale()).obs;

  ThemeMode _readThemeMode() => switch (_store.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Locale _deviceLocale() {
    final code = Get.deviceLocale?.languageCode;
    return AppTranslations.fromCode(code) ?? AppTranslations.fallback;
  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _store.themeMode = mode.name;
    Get.changeThemeMode(mode);
  }

  void setLocale(Locale value) {
    locale.value = value;
    _store.localeCode = AppTranslations.codeOf(value);
    Get.updateLocale(value);
  }

  void toggleLocale() {
    setLocale(
      locale.value.languageCode == 'bn'
          ? AppTranslations.english
          : AppTranslations.bengali,
    );
  }
}
