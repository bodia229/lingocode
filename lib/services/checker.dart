/// Lightweight answer checker for offline Python exercises.
/// We don't run real Python on-device; instead each exercise carries an
/// `expected` string that is matched against the learner's normalized answer.
class AnswerChecker {
  static String normalize(String s) {
    return s
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n+'), '\n')
        .trim()
        .toLowerCase();
  }

  static bool isCorrect(String userAnswer, String expected,
      {List<String> alternatives = const []}) {
    final u = normalize(userAnswer);
    if (u == normalize(expected)) return true;
    for (final alt in alternatives) {
      if (u == normalize(alt)) return true;
    }
    return false;
  }
}
