import 'dart:math';

import 'package:flutter/material.dart';

import '../data/progress.dart';
import '../game/level.dart';
import '../theme.dart';
import 'level_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin =
      AnimationController(vsync: this, duration: const Duration(seconds: 40))
        ..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _open(Level l) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => levelScreen(l)));

  /// Spor, tih ukras u pozadini: tri kvadrata koji se polako okreću.
  Widget _square(double size, double phase, double speed, Alignment at) {
    return Align(
      alignment: at,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, _) => Transform.rotate(
          angle: phase + _spin.value * 2 * pi * speed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: C.teal.withValues(alpha: .07),
              border: Border.all(color: C.teal.withValues(alpha: .35), width: 2),
              borderRadius: BorderRadius.circular(size * .12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(Level level, int i) {
    final unlocked = level.number <= progress.unlocked;
    final best = progress.bestFor(level.number);
    return TweenAnimationBuilder<double>(
      key: ValueKey(level.number),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + i * 50),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: child),
      ),
      child: Opacity(
        opacity: unlocked ? 1 : .4,
        child: Material(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: unlocked ? () => _open(level) : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: C.card2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: level.kind == LevelKind.compass
                            ? const Icon(Icons.explore, size: 18, color: C.accent)
                            : Text('${level.shownNo}',
                                style: const TextStyle(
                                    fontFamily: displayFont, fontSize: 14)),
                      ),
                      const Spacer(),
                      if (!unlocked)
                        const Icon(Icons.lock, size: 18, color: C.muted),
                    ],
                  ),
                  const Spacer(),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(level.title.toUpperCase(),
                        style: const TextStyle(
                            fontFamily: displayFont,
                            fontSize: 22,
                            letterSpacing: .5)),
                  ),
                  const SizedBox(height: 2),
                  Text(best > 0 ? '$best' : '—',
                      style: const TextStyle(color: C.muted, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _square(220, .3, 1, const Alignment(1.2, -.85)),
          _square(140, 1.1, -1.5, const Alignment(-1.3, -.35)),
          _square(90, .6, 2, const Alignment(.9, -.1)),
          SafeArea(
            child: ListenableBuilder(
              listenable: progress,
              builder: (context, _) {
                final current = Level.all[
                    min(progress.unlocked, Level.all.length) - 1];
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('RUTE',
                                style: TextStyle(
                                    fontFamily: displayFont,
                                    fontSize: 72,
                                    height: 1,
                                    letterSpacing: 4)),
                            const SizedBox(height: 8),
                            const Text('NOVI SAD · POGODI ADRESU',
                                style: TextStyle(
                                    color: C.muted, letterSpacing: 2.5)),
                            const SizedBox(height: 36),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(64),
                                shape: const StadiumBorder(),
                                backgroundColor: C.accent,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () => _open(current),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.play_arrow_rounded, size: 30),
                                  const SizedBox(width: 8),
                                  Text('IGRAJ · ${current.title.toUpperCase()}',
                                      style: const TextStyle(
                                          fontFamily: displayFont,
                                          fontSize: 18)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text('NIVOI',
                                style: TextStyle(
                                    color: C.muted,
                                    letterSpacing: 3,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      sliver: SliverGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.35,
                        children: [
                          for (var i = 0; i < Level.all.length; i++)
                            _tile(Level.all[i], i),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
