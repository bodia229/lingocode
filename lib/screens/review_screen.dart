import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/achievement.dart';
import '../models/flashcard.dart';
import '../services/database.dart';
import '../services/feedback_service.dart';
import '../services/game_service.dart';
import '../services/srs.dart';
import '../services/streak.dart';

class ReviewScreen extends StatefulWidget {
  final String? topic;
  const ReviewScreen({super.key, this.topic});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _confetti = ConfettiController(duration: const Duration(seconds: 2));

  List<Flashcard> _queue = [];
  int _index = 0;
  bool _showAnswer = false;
  bool _loading = true;

  int _reviewed = 0;
  int _mistakes = 0;
  int _combo = 0;
  int _maxCombo = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cards = await Db.instance.dueCards(
        type: CardType.english, topic: widget.topic, limit: 30);
    if (cards.isEmpty) {
      if (widget.topic != null) {
        _queue = await Db.instance.cardsForTopic(widget.topic!,
            type: CardType.english, limit: 10);
      } else {
        final db = await Db.instance.database;
        final rows = await db.query('flashcards',
            where: 'type = ?',
            whereArgs: [CardType.english.name],
            orderBy: 'next_review ASC',
            limit: 10);
        _queue = rows.map(Flashcard.fromMap).toList();
      }
    } else {
      _queue = cards;
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _grade(Grade g) async {
    final card = _queue[_index];
    Srs.schedule(card, g);
    await Db.instance.updateCard(card);

    _reviewed += 1;
    if (g == Grade.again) {
      _mistakes += 1;
      _combo = 0;
      await FeedbackService.wrong();
    } else {
      _combo += 1;
      if (_combo > _maxCombo) _maxCombo = _combo;
      await FeedbackService.correct();
    }

    final xpDelta = switch (g) {
      Grade.again => 1,
      Grade.hard => 3,
      Grade.good => 5,
      Grade.easy => 7,
    };
    await StreakService.addXp(xpDelta);
    await GameService.incReviewed(1);
    await GameService.bumpDailyReviewed();
    if (g != Grade.again) {
      await StreakService.bumpForReviewToday();
    }

    if (_index + 1 >= _queue.length) {
      if (!mounted) return;
      await _finishSession();
      return;
    }
    setState(() {
      _index += 1;
      _showAnswer = false;
    });
  }

  Future<void> _finishSession() async {
    await GameService.maybeRecordCombo(_maxCombo);
    if (_mistakes == 0 && _reviewed > 0) {
      await GameService.recordPerfectSession();
    }
    final newAchievements = await _evaluateAchievements();

    if (!mounted) return;
    if (newAchievements.isNotEmpty || _mistakes == 0) {
      _confetti.play();
    }
    _showSummary(newAchievements);
  }

  Future<List<Achievement>> _evaluateAchievements() async {
    final reviewed = await GameService.reviewedTotal();
    final streak = await StreakService.streak();
    final xp = await StreakService.xp();
    final perfect = await GameService.perfectSessions();
    final combo = await GameService.comboBest();
    final learned = await Db.instance.countLearned(type: CardType.english);
    final progress = await Db.instance.allLessonProgress();
    final lessons = progress.where((p) => p.isComplete).length;

    return GameService.evaluate(GameMetrics(
      cardsReviewed: reviewed,
      streakDays: streak,
      xpEarned: xp,
      lessonsCompleted: lessons,
      cardsLearned: learned,
      perfectSessions: perfect,
      comboBest: combo,
    ));
  }

  void _showSummary(List<Achievement> newAchievements) {
    final perfect = _mistakes == 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(context.tr('session_complete')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(perfect
                ? context.tr('session_perfect', {'n': _reviewed})
                : context.tr('session_summary', {'n': _reviewed})),
            if (_maxCombo >= 3) ...[
              const SizedBox(height: 8),
              Text('🎯 ${context.tr('combo')}: $_maxCombo'),
            ],
            if (newAchievements.isNotEmpty) ...[
              const Divider(height: 24),
              Text(context.tr('achievement_unlocked'),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...newAchievements.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(a.emoji, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(context.tr(a.titleKey))),
                      ],
                    ),
                  )),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(context.tr('back_to_home')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('review'))),
        body: Center(child: Text(context.tr('no_cards'))),
      );
    }

    final card = _queue[_index];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('review_progress', {'i': _index + 1, 'n': _queue.length})),
        actions: [
          if (_combo >= 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '🎯 $_combo',
                    key: ValueKey(_combo),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _queue.length,
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showAnswer = !_showAnswer),
                    child: Card(
                      color: cs.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card.front,
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onPrimaryContainer),
                            ),
                            if (card.hint != null) ...[
                              const SizedBox(height: 8),
                              Text('${context.tr('hint_prefix')}${card.hint}',
                                  style: TextStyle(
                                      color: cs.onPrimaryContainer.withOpacity(.8))),
                            ],
                            const SizedBox(height: 24),
                            AnimatedCrossFade(
                              duration: const Duration(milliseconds: 200),
                              firstChild: Text(
                                context.tr('tap_to_reveal'),
                                style: TextStyle(
                                    color: cs.onPrimaryContainer.withOpacity(.6)),
                              ),
                              secondChild: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.back,
                                    style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w500,
                                        color: cs.onPrimaryContainer),
                                  ),
                                  if (card.example != null) ...[
                                    const SizedBox(height: 12),
                                    Text(card.example!,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: cs.onPrimaryContainer
                                                .withOpacity(.85))),
                                  ],
                                ],
                              ),
                              crossFadeState: _showAnswer
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (!_showAnswer)
                  FilledButton(
                    onPressed: () => setState(() => _showAnswer = true),
                    child: Text(context.tr('show_answer')),
                  )
                else
                  Row(
                    children: [
                      _gradeBtn(context.tr('again'), Grade.again, Colors.red),
                      _gradeBtn(context.tr('hard'), Grade.hard, Colors.orange),
                      _gradeBtn(context.tr('good'), Grade.good, Colors.green),
                      _gradeBtn(context.tr('easy'), Grade.easy, Colors.blue),
                    ],
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 18,
              minBlastForce: 6,
              numberOfParticles: 24,
              gravity: 0.25,
              emissionFrequency: 0.04,
              shouldLoop: false,
              colors: const [
                Colors.amber,
                Colors.pink,
                Colors.cyan,
                Colors.green,
                Colors.deepPurple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeBtn(String label, Grade g, Color color) {
    final interval = Srs.previewInterval(_queue[_index], g);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: color),
          onPressed: () => _grade(g),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${interval}d', style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
