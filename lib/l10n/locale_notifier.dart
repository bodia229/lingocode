import 'package:flutter/widgets.dart';
import '../services/database.dart';

class LocaleNotifier extends ChangeNotifier {
  static const _key = 'locale';

  Locale _locale;
  Locale get locale => _locale;

  LocaleNotifier(this._locale);

  static Future<LocaleNotifier> load() async {
    final saved = await Db.instance.getStat(_key);
    final code = saved ?? _systemLocaleCode();
    return LocaleNotifier(_localeFromCode(code));
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    await Db.instance.setStat(_key, locale.languageCode);
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
}
