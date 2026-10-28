import 'package:flutter/material.dart';

import '../theme.dart';

/// Odbrojavanje 3, 2, 1: broj iskoči (elastično) i pojavi se, a prsten oko
/// njega se isprazni za jednu sekundu.
class CountdownView extends StatelessWidget {
  final int n;
  const CountdownView(this.n, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                key: ValueKey('ring$n'),
                tween: Tween(begin: 1, end: 0),
                duration: const Duration(seconds: 1),
                builder: (_, v, _) => SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: v,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: C.teal,
                    backgroundColor: C.card2,
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                key: ValueKey('num$n'),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (_, v, child) => Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.scale(scale: .4 + .6 * v, child: child),
                ),
                child: Text(
                  '$n',
                  style: const TextStyle(
                    fontFamily: displayFont,
                    fontSize: 120,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
