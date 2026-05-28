import 'dart:math';
import '../models/achievement.dart';
import 'database.dart';

/// Stats snapshot used to evaluate achievements.
class GameMetrics {
  final int cardsReviewed;
  final int streakDays;
  final int xpEarned;
  final int lessonsCompleted;
  final int cardsLearned;
  final int perfectSessions;
  final int comboBest;

  const GameMetrics({
    required this.cardsReviewed,
    required this.streakDays,
    required this.xpEarned,
    required this.lessonsCompleted,
    required this.cardsLearned,
    required this.perfectSessions,
    required this.comboBest,
  });

  int valueFor(AchievementMetric m) {
    switch (m) {
      case AchievementMetric.cardsReviewed:
        return cardsReviewed;
      case AchievementMetric.streakDays:
        return streakDays;
      case AchievementMetric.xpEarned:
        return xpEarned;
      case AchievementMetric.lessonsCompleted:
        return lessonsCompleted;
      case AchievementMetric.cardsLearned:
        return cardsLearned;
      case AchievementMetric.perfectSessions:
        return perfectSessions;
      case AchievementMetric.comboBest:
        return comboBest;
    }
  }
}

class GameService {
  static const _kReviewedTotal = 'reviewed_total';
  static const _kPerfectSessions = 'perfect_sessions';
  static const _kComboBest = 'combo_best';
  static const _kUnlocked = 'unlocked_achievements';
  static const _kDailyDate = 'daily_date';
  static const _kDailyCount = 'daily_count';
  static const _kDailyGoal = 'daily_goal';

  static const int defaultDailyGoal = 10;
  static const int xpPerLevel = 100;

  // --- Levels --------------------------------------------------------------

  static int levelFromXp(int xp) => xp ~/ xpPerLevel + 1;
  static int xpIntoLevel(int xp) => xp % xpPerLevel;
  static double levelProgress(int xp) => xpIntoLevel(xp) / xpPerLevel;

  // --- Counters ------------------------------------------------------------

  static Future<int> reviewedTotal() async =>
      int.tryParse(await Db.instance.getStat(_kReviewedTotal) ?? '') ?? 0;

  static Future<int> incReviewed(int delta) async {
    final v = await reviewedTotal() + delta;
    await Db.instance.setStat(_kReviewedTotal, v.toString());
    return v;
  }

  static Future<int> perfectSessions() async =>
      int.tryParse(await Db.instance.getStat(_kPerfectSessions) ?? '') ?? 0;

  static Future<int> recordPerfectSession() async {
    final v = await perfectSessions() + 1;
    await Db.instance.setStat(_kPerfectSessions, v.toString());
    return v;
  }

  static Future<int> comboBest() async =>
      int.tryParse(await Db.instance.getStat(_kComboBest) ?? '') ?? 0;

  static Future<int> maybeRecordCombo(int combo) async {
    final best = await comboBest();
    if (combo > best) {
      await Db.instance.setStat(_kComboBest, combo.toString());
      return combo;
    }
    return best;
  }

  // --- Daily goal ----------------------------------------------------------

  static Future<int> dailyGoal() async =>
      int.tryParse(await Db.instance.getStat(_kDailyGoal) ?? '') ??
          defaultDailyGoal;

  static Future<void> setDailyGoal(int goal) async {
    await Db.instance.setStat(_kDailyGoal, max(1, goal).toString());
  }

  static String _today() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static Future<int> dailyReviewed() async {
    final day = await Db.instance.getStat(_kDailyDate);
    if (day != _today()) return 0;
    return int.tryParse(await Db.instance.getStat(_kDailyCount) ?? '') ?? 0;
  }

  static Future<int> bumpDailyReviewed() async {
    final day = await Db.instance.getStat(_kDailyDate);
    int current = (day == _today())
        ? (int.tryParse(await Db.instance.getStat(_kDailyCount) ?? '') ?? 0)
        : 0;
    current += 1;
    await Db.instance.setStat(_kDailyDate, _today());
    await Db.instance.setStat(_kDailyCount, current.toString());
    return current;
  }

  // --- Achievements --------------------------------------------------------

  static Future<Set<String>> unlockedIds() async {
    final raw = await Db.instance.getStat(_kUnlocked);
    if (raw == null || raw.isEmpty) return <String>{};
    return raw.split(',').toSet();
  }

  static Future<void> _saveUnlocked(Set<String> ids) async {
    await Db.instance.setStat(_kUnlocked, ids.join(','));
  }

  /// Evaluate achievements against current metrics and return any newly
  /// unlocked ones (so the UI can show a toast / confetti).
  static Future<List<Achievement>> evaluate(GameMetrics m) async {
    final unlocked = await unlockedIds();
    final newlyUnlocked = <Achievement>[];
    for (final a in Achievements.all) {
      if (unlocked.contains(a.id)) continue;
      if (m.valueFor(a.metric) >= a.threshold) {
        unlocked.add(a.id);
        newlyUnlocked.add(a);
      }
    }
    if (newlyUnlocked.isNotEmpty) {
      await _saveUnlocked(unlocked);
    }
    return newlyUnlocked;
  }
}
