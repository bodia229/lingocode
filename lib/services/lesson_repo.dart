import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/lesson.dart';

class LessonRepository {
  List<Lesson>? _cache;

  Future<List<Lesson>> all() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/python_lessons.json');
    final list = (jsonDecode(raw) as List)
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    _cache = list;
    return list;
  }

  Future<Lesson?> byId(String id) async {
    final lessons = await all();
    for (final l in lessons) {
      if (l.id == id) return l;
    }
    return null;
  }
}
