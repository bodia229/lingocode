import 'package:flutter/material.dart';

import '../models/flashcard.dart';
import '../services/database.dart';
import '../services/streak.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _streak = 0;
  int _xp = 0;
  int _due = 0;
  int _learned = 0;
  int _total = 0;
  int _lessonsCompleted = 0;
  DateTime? _lastActive;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final streak = await StreakService.streak();
    final xp = await StreakService.xp();
    final due = await Db.instance.countDue(type: CardType.english);
    final learned = await Db.instance.countLearned(type: CardType.english);
    final total = await Db.instance.countTotal(type: CardType.english);
    final progress = await Db.instance.allLessonProgress();
    final last = await StreakService.lastActive();
    if (!mounted) return;
    setState(() {
      _streak = streak;
      _xp = xp;
      _due = due;
      _learned = learned;
      _total = total;
      _lessonsCompleted = progress.where((p) => p.isComplete).length;
      _lastActive = last;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _statRow('Current streak', '$_streak days', Icons.local_fire_department),
          _statRow('Total XP', '$_xp', Icons.bolt),
          const Divider(height: 32),
          _statRow('English cards due', '$_due', Icons.menu_book),
          _statRow('Cards learned', '$_learned / $_total', Icons.psychology),
          const Divider(height: 32),
          _statRow('Python lessons completed', '$_lessonsCompleted', Icons.code),
          if (_lastActive != null) ...[
            const Divider(height: 32),
            _statRow(
              'Last active',
              '${_lastActive!.year}-${_lastActive!.month.toString().padLeft(2, '0')}-${_lastActive!.day.toString().padLeft(2, '0')}',
              Icons.event,
            ),
          ],
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
