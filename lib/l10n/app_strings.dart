import 'package:flutter/widgets.dart';

/// Lightweight i18n: keys → per-locale translations.
/// Use via `context.tr('key')` extension below.
class AppStrings extends InheritedWidget {
  final Locale locale;
  const AppStrings({super.key, required this.locale, required super.child});

  static const supported = [
    Locale('en'),
    Locale('uk'),
    Locale('ru'),
  ];

  static AppStrings of(BuildContext context) {
    final w = context.dependOnInheritedWidgetOfExactType<AppStrings>();
    assert(w != null, 'AppStrings missing from widget tree');
    return w!;
  }

  String t(String key) {
    final code = locale.languageCode;
    final row = _data[key];
    if (row == null) return key;
    return row[code] ?? row['en'] ?? key;
  }

  @override
  bool updateShouldNotify(AppStrings oldWidget) => oldWidget.locale != locale;

  static const Map<String, Map<String, String>> _data = {
    'app_title': {
      'en': 'LingoCode',
      'uk': 'LingoCode',
      'ru': 'LingoCode',
    },
    'stats': {
      'en': 'Stats',
      'uk': 'Статистика',
      'ru': 'Статистика',
    },
    'settings': {
      'en': 'Settings',
      'uk': 'Налаштування',
      'ru': 'Настройки',
    },
    'language': {
      'en': 'Language',
      'uk': 'Мова',
      'ru': 'Язык',
    },
    'streak': {
      'en': 'Streak',
      'uk': 'Серія',
      'ru': 'Серия',
    },
    'xp': {
      'en': 'XP',
      'uk': 'XP',
      'ru': 'XP',
    },
    'english_flashcards': {
      'en': 'English flashcards',
      'uk': 'Англійські картки',
      'ru': 'Английские карточки',
    },
    'cards_due_now': {
      'en': '{n} cards due now',
      'uk': '{n} карток до перегляду',
      'ru': '{n} карточек для повтора',
    },
    'learned_x_of_y': {
      'en': 'Learned {a} of {b}',
      'uk': 'Вивчено {a} з {b}',
      'ru': 'Изучено {a} из {b}',
    },
    'start_review': {
      'en': 'Start review',
      'uk': 'Розпочати повтор',
      'ru': 'Начать повтор',
    },
    'review_anyway': {
      'en': 'Review anyway',
      'uk': 'Повторити все одно',
      'ru': 'Повторить всё равно',
    },
    'python_lessons': {
      'en': 'Python lessons',
      'uk': 'Уроки Python',
      'ru': 'Уроки Python',
    },
    'open_lessons': {
      'en': 'Open lessons',
      'uk': 'Відкрити уроки',
      'ru': 'Открыть уроки',
    },
    'lessons_subtitle': {
      'en': 'Interactive exercises with instant feedback.',
      'uk': 'Інтерактивні вправи з миттєвим відгуком.',
      'ru': 'Интерактивные упражнения с мгновенной обратной связью.',
    },
    'tip_title': {
      'en': 'Tip',
      'uk': 'Порада',
      'ru': 'Совет',
    },
    'tip_body': {
      'en': 'Daily reviews protect your streak. Even 5 cards a day keeps long-term retention up.',
      'uk': 'Щоденні повтори зберігають вашу серію. Навіть 5 карток на день підтримують довготривалу пам’ять.',
      'ru': 'Ежедневные повторы сохраняют серию. Даже 5 карточек в день поддерживают долгосрочную память.',
    },

    // Review screen
    'review': {
      'en': 'Review',
      'uk': 'Повтор',
      'ru': 'Повтор',
    },
    'review_progress': {
      'en': 'Review  {i} / {n}',
      'uk': 'Повтор  {i} / {n}',
      'ru': 'Повтор  {i} / {n}',
    },
    'show_answer': {
      'en': 'Show answer',
      'uk': 'Показати відповідь',
      'ru': 'Показать ответ',
    },
    'tap_to_reveal': {
      'en': 'Tap to reveal answer',
      'uk': 'Натисніть, щоб побачити відповідь',
      'ru': 'Нажмите, чтобы увидеть ответ',
    },
    'hint_prefix': {
      'en': 'Hint: ',
      'uk': 'Підказка: ',
      'ru': 'Подсказка: ',
    },
    'again': {
      'en': 'Again',
      'uk': 'Знову',
      'ru': 'Снова',
    },
    'hard': {
      'en': 'Hard',
      'uk': 'Важко',
      'ru': 'Сложно',
    },
    'good': {
      'en': 'Good',
      'uk': 'Добре',
      'ru': 'Хорошо',
    },
    'easy': {
      'en': 'Easy',
      'uk': 'Легко',
      'ru': 'Легко',
    },
    'session_complete': {
      'en': 'Session complete',
      'uk': 'Сесію завершено',
      'ru': 'Сессия завершена',
    },
    'session_summary': {
      'en': 'You reviewed {n} cards. Nice work.',
      'uk': 'Ви повторили {n} карток. Чудова робота.',
      'ru': 'Вы повторили {n} карточек. Отличная работа.',
    },
    'back_to_home': {
      'en': 'Back to home',
      'uk': 'На головну',
      'ru': 'На главную',
    },
    'no_cards': {
      'en': 'No cards yet. Add some first.',
      'uk': 'Немає карток. Додайте спочатку.',
      'ru': 'Карточек ещё нет. Сначала добавьте.',
    },

    // Lesson screens
    'lesson_progress': {
      'en': 'Exercise {i} of {n}',
      'uk': 'Вправа {i} з {n}',
      'ru': 'Упражнение {i} из {n}',
    },
    'correct': {
      'en': 'Correct!',
      'uk': 'Правильно!',
      'ru': 'Правильно!',
    },
    'wrong_expected': {
      'en': 'Wrong. Expected: {expected}',
      'uk': 'Неправильно. Очікувалось: {expected}',
      'ru': 'Неверно. Ожидалось: {expected}',
    },
    'not_quite_expected': {
      'en': 'Not quite. Expected: {expected}',
      'uk': 'Не зовсім. Очікувалось: {expected}',
      'ru': 'Не совсем. Ожидалось: {expected}',
    },
    'check': {
      'en': 'Check',
      'uk': 'Перевірити',
      'ru': 'Проверить',
    },
    'next': {
      'en': 'Next',
      'uk': 'Далі',
      'ru': 'Далее',
    },
    'finish': {
      'en': 'Finish',
      'uk': 'Завершити',
      'ru': 'Завершить',
    },
    'your_answer': {
      'en': 'Your answer',
      'uk': 'Ваша відповідь',
      'ru': 'Ваш ответ',
    },

    // Stats screen
    'current_streak': {
      'en': 'Current streak',
      'uk': 'Поточна серія',
      'ru': 'Текущая серия',
    },
    'days_value': {
      'en': '{n} days',
      'uk': '{n} дн.',
      'ru': '{n} дн.',
    },
    'total_xp': {
      'en': 'Total XP',
      'uk': 'Всього XP',
      'ru': 'Всего XP',
    },
    'english_due': {
      'en': 'English cards due',
      'uk': 'Карток до перегляду',
      'ru': 'Карточек к повтору',
    },
    'cards_learned': {
      'en': 'Cards learned',
      'uk': 'Вивчено карток',
      'ru': 'Изучено карточек',
    },
    'lessons_completed': {
      'en': 'Python lessons completed',
      'uk': 'Завершено уроків Python',
      'ru': 'Завершено уроков Python',
    },
    'last_active': {
      'en': 'Last active',
      'uk': 'Останній вхід',
      'ru': 'Последний вход',
    },

    // Theme
    'theme': {
      'en': 'Theme',
      'uk': 'Тема',
      'ru': 'Тема',
    },
    'theme_system': {
      'en': 'Follow system',
      'uk': 'Як у системі',
      'ru': 'Как в системе',
    },
    'theme_light': {
      'en': 'Light',
      'uk': 'Світла',
      'ru': 'Светлая',
    },
    'theme_dark': {
      'en': 'Dark',
      'uk': 'Темна',
      'ru': 'Тёмная',
    },

    // Languages
    'lang_en': {
      'en': 'English',
      'uk': 'Англійська',
      'ru': 'Английский',
    },
    'lang_uk': {
      'en': 'Ukrainian',
      'uk': 'Українська',
      'ru': 'Украинский',
    },
    'lang_ru': {
      'en': 'Russian',
      'uk': 'Російська',
      'ru': 'Русский',
    },
  };
}

extension AppStringsX on BuildContext {
  String tr(String key, [Map<String, Object>? params]) {
    final raw = AppStrings.of(this).t(key);
    if (params == null) return raw;
    var out = raw;
    params.forEach((k, v) => out = out.replaceAll('{$k}', '$v'));
    return out;
  }
}
