import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/flashcard.dart';
import '../services/database.dart';
import '../services/srs.dart';
import '../services/streak.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _tts = FlutterTts();
  List<Flashcard> _queue = [];
  int _index = 0;
  bool _showAnswer = false;
  bool _loading = true;
  int _reviewed = 0;

  @override
  void initState() {
    super.initState();
    _setupTts();
    _load();
  }

  Future<void> _setupTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1);
    } catch (_) {}
  }

  Future<void> _load() async {
    final cards = await Db.instance.dueCards(type: CardType.english, limit: 30);
    if (cards.isEmpty) {
      // If nothing is due, surface the soonest 10 cards anyway for free practice.
      final db = await Db.instance.database;
      final rows = await db.query('flashcards',
          where: 'type = ?',
          whereArgs: [CardType.english.name],
          orderBy: 'next_review ASC',
          limit: 10);
      _queue = rows.map(Flashcard.fromMap).toList();
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
    final xpDelta = switch (g) {
      Grade.again => 1,
      Grade.hard => 3,
      Grade.good => 5,
      Grade.easy => 7,
    };
    await StreakService.addXp(xpDelta);
    if (g != Grade.again) {
      await StreakService.bumpForReviewToday();
    }

    if (_index + 1 >= _queue.length) {
      if (!mounted) return;
      _showSummary();
      return;
    }
    setState(() {
      _index += 1;
      _showAnswer = false;
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  void _showSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Session complete'),
        content: Text('You reviewed $_reviewed cards. Nice work.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to home'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_queue.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review')),
        body: const Center(child: Text('No cards yet. Add some first.')),
      );
    }

    final card = _queue[_index];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review  ${_index + 1} / ${_queue.length}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / _queue.length,
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
      ),
      body: Padding(
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                card.front,
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onPrimaryContainer),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              color: cs.onPrimaryContainer,
                              onPressed: () => _speak(card.audioText ?? card.front),
                            ),
                          ],
                        ),
                        if (card.hint != null) ...[
                          const SizedBox(height: 8),
                          Text('Hint: ${card.hint}',
                              style: TextStyle(
                                  color: cs.onPrimaryContainer.withOpacity(.8))),
                        ],
                        const SizedBox(height: 24),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          firstChild: Text(
                            'Tap to reveal answer',
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
                                        color: cs.onPrimaryContainer.withOpacity(.85))),
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
                child: const Text('Show answer'),
              )
            else
              Row(
                children: [
                  _gradeBtn('Again', Grade.again, Colors.red),
                  _gradeBtn('Hard', Grade.hard, Colors.orange),
                  _gradeBtn('Good', Grade.good, Colors.green),
                  _gradeBtn('Easy', Grade.easy, Colors.blue),
                ],
              ),
          ],
        ),
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
