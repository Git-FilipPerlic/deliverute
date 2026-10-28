import 'package:flutter/material.dart';

import '../game/level.dart';
import '../screens/level_screen.dart';

/// Kraj igre: rezultat + Sledeći nivo / Opet / Nazad.
class ResultView extends StatelessWidget {
  final Level level;
  final int correct;
  final int points;
  final Duration avgTime;
  final bool passed;
  const ResultView({
    super.key,
    required this.level,
    required this.correct,
    required this.points,
    required this.avgTime,
    required this.passed,
  });

  @override
  Widget build(BuildContext context) {
    final next =
        level.number < Level.all.length ? Level.all[level.number] : null;
    void go(Level l) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => levelScreen(l)));
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tačno: $correct/10\n'
              'Poeni: $points\n'
              'Prosek: ${avgTime.inMilliseconds} ms',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 12),
            Text(passed
                ? (next != null
                    ? 'Prošao si! Otključano: ${next.title}.'
                    : 'Prošao si!')
                : 'Treba ti ${Level.passMark} tačnih za sledeći nivo.'),
            const SizedBox(height: 24),
            if (passed && next != null)
              FilledButton(
                onPressed: () => go(next),
                child: Text(next.title),
              ),
            TextButton(onPressed: () => go(level), child: const Text('Opet')),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Nazad'),
            ),
          ],
        ),
      ),
    );
  }
}
