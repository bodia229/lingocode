import 'package:flutter/material.dart';
import '../services/database.dart';

/// Holds user-selected app preferences (locale + theme mode), persisted in SQLite.
class AppPrefs extends ChangeNotifier {
  static const _kLocale = 'locale';
  static const _kTheme = 'theme_mode';

  Locale _locale;
  ThemeMode _themeMode;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  AppPrefs(this._locale, this._themeMode);

  static Future<AppPrefs> load() async {
    final savedLocale = await Db.instance.getStat(_kLocale);
    final savedTheme = await Db.instance.getStat(_kTheme);
    final code = savedLocale ?? _systemLocaleCode();
    final mode = _modeFromString(savedTheme);
    return AppPrefs(_localeFromCode(code), mode);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    await Db.instance.setStat(_kLocale, locale.languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await Db.instance.setStat(_kTheme, mode.name);
    notifyListeners();
  }

  static String _systemLocaleCode() {
    final platform = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (platform == 'uk' || platform == 'ru' || platform == 'en') return platform;
    return 'en';
  }

  static Locale _localeFromCode(String code) {
    switch (code) {
      case 'uk':
      case 'ru':
      case 'en':
        return Locale(code);
      default:
        return const Locale('en');
    }
  }

  static ThemeMode _modeFromString(String? s) {
    switch (s) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

// Backwards-compatible alias for screens that imported LocaleNotifier.
typedef LocaleNotifier = AppPrefs;
