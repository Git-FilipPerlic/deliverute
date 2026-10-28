import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Otključani nivoi i najbolji rezultati, čuvaju se lokalno.
class Progress extends ChangeNotifier {
  late SharedPreferences _prefs;
  int _unlocked = 1;
  final Map<int, int> _best = {};

  int get unlocked => _unlocked;
  int bestFor(int level) => _best[level] ?? 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _unlocked = _prefs.getInt('unlocked') ?? 1;
    for (var l = 1; l <= 99; l++) {
      final b = _prefs.getInt('best_$l');
      if (b != null) _best[l] = b;
    }
  }

  void record({required int level, required int points, required bool passed}) {
    if (points > bestFor(level)) {
      _best[level] = points;
      _prefs.setInt('best_$level', points);
    }
    if (passed && level >= _unlocked) {
      _unlocked = level + 1;
      _prefs.setInt('unlocked', _unlocked);
    }
    notifyListeners();
  }
}

final progress = Progress();
