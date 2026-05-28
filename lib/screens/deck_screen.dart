import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/flashcard.dart';
import '../services/database.dart';
import 'review_screen.dart';

class DeckScreen extends StatefulWidget {
  const DeckScreen({super.key});
  @override
  State<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends State<DeckScreen> {
  List<Flashcard> _all = const [];
  List<String> _topics = const [];
  String? _activeTopic;
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await Db.instance.database;
    final rows = await db.query('flashcards',
        where: 'type = ?',
        whereArgs: [CardType.english.name],
        orderBy: 'topic ASC, front ASC');
    final cards = rows.map(Flashcard.fromMap).toList();
    final topics = (cards.map((c) => c.topic).toSet().toList()..sort());
    if (!mounted) return;
    setState(() {
      _all = cards;
      _topics = topics;
      _loading = false;
    });
  }

  List<Flashcard> get _filtered {
    Iterable<Flashcard> base = _all;
    if (_activeTopic != null) {
      base = base.where((c) => c.topic == _activeTopic);
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      base = base.where((c) =>
          c.front.toLowerCase().contains(q) ||
          c.back.toLowerCase().contains(q));
    }
    return base.toList();
  }

  double _topicMastery(String topic) {
    final inTopic = _all.where((c) => c.topic == topic).toList();
    if (inTopic.isEmpty) return 0;
    final learned = inTopic.where((c) => c.repetitions > 0).length;
    return learned / inTopic.length;
  }

  Future<void> _resetCard(Flashcard c) async {
    c.ease = 2.5;
    c.intervalDays = 0;
    c.repetitions = 0;
    c.nextReview = DateTime.now();
    c.lapses = 0;
    await Db.instance.updateCard(c);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('deck'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final cards = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('deck')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    filled: true,
                    isDense: true,
                    prefixIcon: const Icon(Icons.search),
                    hintText: context.tr('search_cards'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _topicChip(context.tr('all_topics'), null),
                      ..._topics.map((t) => _topicChip(t, t)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _activeTopic == null
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.play_arrow),
              label: Text(context.tr('review_topic_btn')),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ReviewScreen(topic: _activeTopic)));
                _load();
              },
            ),
      body: cards.isEmpty
          ? Center(child: Text(context.tr('no_cards')))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: cards.length,
              itemBuilder: (_, i) {
                final c = cards[i];
                final learned = c.repetitions > 0;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: ListTile(
                    title: Text(c.front,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.back),
                    leading: CircleAvatar(
                      backgroundColor:
                          learned ? Colors.green : cs.surfaceContainerHighest,
                      foregroundColor: learned ? Colors.white : cs.onSurface,
                      child: Text('${c.repetitions}',
                          style: const TextStyle(fontSize: 14)),
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 'reset', child: Text('Reset progress')),
                      ],
                      onSelected: (v) {
                        if (v == 'reset') _resetCard(c);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _topicChip(String label, String? topicKey) {
    final cs = Theme.of(context).colorScheme;
    final selected = _activeTopic == topicKey;
    final mastery = topicKey == null ? null : _topicMastery(topicKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (mastery != null) ...[
              const SizedBox(width: 6),
              Text('${(mastery * 100).round()}%',
                  style: TextStyle(
                      fontSize: 11,
                      color: selected ? cs.onPrimary : cs.onSurfaceVariant)),
            ],
          ],
        ),
        selected: selected,
        onSelected: (_) {
          setState(() => _activeTopic = selected ? null : topicKey);
        },
      ),
    );
  }
}
