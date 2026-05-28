import 'database.dart';

class StreakService {
  static const _kStreak = 'streak';
  static const _kLastActive = 'last_active';
  static const _kXp = 'xp';

  static Future<int> streak() async {
    final v = await Db.instance.getStat(_kStreak);
    return int.tryParse(v ?? '') ?? 0;
  }

  static Future<int> xp() async {
    final v = await Db.instance.getStat(_kXp);
    return int.tryParse(v ?? '') ?? 0;
  }

  static Future<DateTime?> lastActive() async {
    final v = await Db.instance.getStat(_kLastActive);
    if (v == null) return null;
    return DateTime.tryParse(v);
  }

  static Future<int> bumpForReviewToday() async {
    final last = await lastActive();
    final today = _dateOnly(DateTime.now());
    int current = await streak();
    if (last == null) {
      current = 1;
    } else {
      final lastDay = _dateOnly(last);
      final diff = today.difference(lastDay).inDays;
      if (diff == 0) {
        // already counted today
      } else if (diff == 1) {
        current += 1;
      } else {
        current = 1;
      }
    }
    await Db.instance.setStat(_kStreak, current.toString());
    await Db.instance.setStat(_kLastActive, today.toIso8601String());
    return current;
  }

  static Future<int> addXp(int delta) async {
    final current = await xp();
    final next = current + delta;
    await Db.instance.setStat(_kXp, next.toString());
    return next;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
