import 'package:flutter/material.dart';

import '../game/level.dart';
import '../screens/level_screen.dart';
import '../theme.dart';

/// Kraj igre: rezultat u karticama + Sledeći nivo / Opet / Nazad.
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

  Widget _stat(String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(fontFamily: displayFont, fontSize: 26)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: C.muted)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final next =
        level.number < Level.all.length ? Level.all[level.number] : null;
    void go(Level l) => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => levelScreen(l)));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                passed ? 'PROŠLA SI!' : 'JOŠ MALO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: displayFont,
                  fontSize: 38,
                  color: passed ? C.green : C.accent,
                ),
              ),
              const SizedBox(height: 4),
              Text(level.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: C.muted, letterSpacing: 3)),
              const SizedBox(height: 28),
              Row(children: [
                _stat('tačno', '$correct/10'),
                const SizedBox(width: 12),
                _stat('poeni', '$points'),
                const SizedBox(width: 12),
                _stat('prosek', '${avgTime.inMilliseconds} ms'),
              ]),
              const SizedBox(height: 16),
              Text(
                passed
                    ? (next != null
                        ? 'Otključano: ${next.title}'
                        : 'Svi nivoi su prođeni!')
                    : 'Treba ti ${Level.passMark} tačnih za sledeći nivo.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: C.muted),
              ),
              const Spacer(),
              if (passed && next != null)
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => go(next),
                  child: Text(next.title,
                      style: const TextStyle(
                          fontFamily: displayFont, fontSize: 18)),
                ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => go(level), child: const Text('Opet')),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Nazad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
