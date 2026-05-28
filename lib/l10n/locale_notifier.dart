import 'package:flutter/material.dart';
import '../services/database.dart';
import '../services/feedback_service.dart';

class AppPrefs extends ChangeNotifier {
  static const _kLocale = 'locale';
  static const _kTheme = 'theme_mode';
  static const _kSound = 'sound_enabled';
  static const _kHaptic = 'haptic_enabled';

  Locale _locale;
  ThemeMode _themeMode;
  bool _soundEnabled;
  bool _hapticEnabled;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  AppPrefs(this._locale, this._themeMode, this._soundEnabled, this._hapticEnabled) {
    FeedbackService.soundEnabled = _soundEnabled;
    FeedbackService.hapticEnabled = _hapticEnabled;
  }

  static Future<AppPrefs> load() async {
    final savedLocale = await Db.instance.getStat(_kLocale);
    final savedTheme = await Db.instance.getStat(_kTheme);
    final savedSound = await Db.instance.getStat(_kSound);
    final savedHaptic = await Db.instance.getStat(_kHaptic);
    return AppPrefs(
      _localeFromCode(savedLocale ?? _systemLocaleCode()),
      _modeFromString(savedTheme),
      savedSound != 'false',
      savedHaptic != 'false',
    );
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

  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;
    _soundEnabled = enabled;
    FeedbackService.soundEnabled = enabled;
    await Db.instance.setStat(_kSound, enabled.toString());
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool enabled) async {
    if (_hapticEnabled == enabled) return;
    _hapticEnabled = enabled;
    FeedbackService.hapticEnabled = enabled;
    await Db.instance.setStat(_kHaptic, enabled.toString());
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

typedef LocaleNotifier = AppPrefs;
