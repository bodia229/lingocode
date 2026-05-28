/// Static definition of an achievement.
class Achievement {
  final String id;
  final String titleKey; // translation key in AppStrings
  final String descKey;
  final String emoji;
  final int threshold;
  final AchievementMetric metric;

  const Achievement({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.emoji,
    required this.threshold,
    required this.metric,
  });
}

enum AchievementMetric {
  cardsReviewed,
  streakDays,
  xpEarned,
  lessonsCompleted,
  cardsLearned,
  perfectSessions,
  comboBest,
}

/// Master list of achievements. Add new ones at the end (never reorder).
class Achievements {
  static const all = <Achievement>[
    Achievement(
      id: 'first_steps',
      titleKey: 'ach_first_steps',
      descKey: 'ach_first_steps_desc',
      emoji: '👶',
      threshold: 1,
      metric: AchievementMetric.cardsReviewed,
    ),
    Achievement(
      id: 'reviewed_10',
      titleKey: 'ach_reviewed_10',
      descKey: 'ach_reviewed_10_desc',
      emoji: '🌱',
      threshold: 10,
      metric: AchievementMetric.cardsReviewed,
    ),
    Achievement(
      id: 'reviewed_100',
      titleKey: 'ach_reviewed_100',
      descKey: 'ach_reviewed_100_desc',
      emoji: '🌲',
      threshold: 100,
      metric: AchievementMetric.cardsReviewed,
    ),
    Achievement(
      id: 'reviewed_1000',
      titleKey: 'ach_reviewed_1000',
      descKey: 'ach_reviewed_1000_desc',
      emoji: '🌳',
      threshold: 1000,
      metric: AchievementMetric.cardsReviewed,
    ),
    Achievement(
      id: 'streak_3',
      titleKey: 'ach_streak_3',
      descKey: 'ach_streak_3_desc',
      emoji: '🔥',
      threshold: 3,
      metric: AchievementMetric.streakDays,
    ),
    Achievement(
      id: 'streak_7',
      titleKey: 'ach_streak_7',
      descKey: 'ach_streak_7_desc',
      emoji: '🔥🔥',
      threshold: 7,
      metric: AchievementMetric.streakDays,
    ),
    Achievement(
      id: 'streak_30',
      titleKey: 'ach_streak_30',
      descKey: 'ach_streak_30_desc',
      emoji: '🔥🔥🔥',
      threshold: 30,
      metric: AchievementMetric.streakDays,
    ),
    Achievement(
      id: 'xp_100',
      titleKey: 'ach_xp_100',
      descKey: 'ach_xp_100_desc',
      emoji: '⚡',
      threshold: 100,
      metric: AchievementMetric.xpEarned,
    ),
    Achievement(
      id: 'xp_1000',
      titleKey: 'ach_xp_1000',
      descKey: 'ach_xp_1000_desc',
      emoji: '⚡⚡',
      threshold: 1000,
      metric: AchievementMetric.xpEarned,
    ),
    Achievement(
      id: 'lessons_5',
      titleKey: 'ach_lessons_5',
      descKey: 'ach_lessons_5_desc',
      emoji: '🐍',
      threshold: 5,
      metric: AchievementMetric.lessonsCompleted,
    ),
    Achievement(
      id: 'lessons_all',
      titleKey: 'ach_lessons_all',
      descKey: 'ach_lessons_all_desc',
      emoji: '🏆',
      threshold: 36,
      metric: AchievementMetric.lessonsCompleted,
    ),
    Achievement(
      id: 'learned_50',
      titleKey: 'ach_learned_50',
      descKey: 'ach_learned_50_desc',
      emoji: '📚',
      threshold: 50,
      metric: AchievementMetric.cardsLearned,
    ),
    Achievement(
      id: 'combo_10',
      titleKey: 'ach_combo_10',
      descKey: 'ach_combo_10_desc',
      emoji: '🎯',
      threshold: 10,
      metric: AchievementMetric.comboBest,
    ),
    Achievement(
      id: 'perfect',
      titleKey: 'ach_perfect',
      descKey: 'ach_perfect_desc',
      emoji: '✨',
      threshold: 1,
      metric: AchievementMetric.perfectSessions,
    ),
  ];

  static Achievement? byId(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
