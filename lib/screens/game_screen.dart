import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/progress.dart';
import '../game/game_session.dart';
import '../game/level.dart';
import '../services/score_service.dart';
import '../theme.dart';
import '../widgets/countdown_view.dart';
import '../widgets/game_header.dart';
import '../widgets/result_view.dart';

class GameScreen extends StatefulWidget {
  final Level level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const feedbackTime = Duration(milliseconds: 800);
  static const revealTime = Duration(seconds: 1);

  late final session = GameSession(widget.level);
  late final AnimationController _reveal =
      AnimationController(vsync: this, duration: revealTime);
  int? countdown = 3;
  Round? round;
  bool ready = false; // kvadrati su narasli, vreme teče, klikovi su dozvoljeni
  int? tapped; // -1 = isteklo vreme
  final stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => countdown = countdown! - 1);
      if (countdown == 0) {
        t.cancel();
        setState(() => countdown = null);
        _nextRound();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _reveal.dispose();
    super.dispose();
  }

  void _nextRound() {
    setState(() {
      tapped = null;
      ready = false;
      round = session.nextRound();
    });
    if (MediaQuery.of(context).disableAnimations) {
      _reveal.value = 1;
    } else {
      _reveal.forward(from: 0);
    }
    // vreme počinje tek kad kvadrati narastu
    _timer = Timer(revealTime, () {
      setState(() => ready = true);
      stopwatch
        ..reset()
        ..start();
      _timer = Timer(widget.level.timeLimit, () => _answer(-1));
    });
  }

  void _answer(int i) {
    if (tapped != null || !ready) return;
    _timer?.cancel();
    stopwatch.stop();
    final took = i == -1 ? widget.level.timeLimit : stopwatch.elapsed;
    session.answer(i == round!.correctIndex, took);
    setState(() => tapped = i);
    _timer = Timer(feedbackTime, () {
      if (!mounted) return;
      if (session.finished) {
        progress.record(
          level: widget.level.number,
          points: session.points,
          passed: session.passed,
        );
        ScoreService()
            .submit(correct: session.correct, avgTime: session.avgTime);
        setState(() => round = null);
      } else {
        _nextRound();
      }
    });
  }

  void _onMapTap(LatLng p) {
    final r = round;
    if (r == null || tapped != null || !ready) return;
    final i = r.squares.indexWhere((s) => s.contains(p));
    if (i != -1) _answer(i);
  }

  Color _fill(int i) {
    if (tapped == null) return C.teal;
    if (i == round!.correctIndex) return C.green;
    if (i == tapped) return C.red;
    return C.muted;
  }

  /// Kvadrat pri otkrivanju: raste (sa blagim preskokom), rasteže se i okreće.
  List<LatLng> _corners(Square s, double t) {
    const k = 0.707; // stepen geografske dužine je kraći od stepena širine
    final e = Curves.easeOutBack.transform(t).clamp(0.001, 2.0);
    final stretch = sin(pi * t);
    final sx = 1 + .35 * stretch, sy = 1 - .2 * stretch;
    final ang = (1 - Curves.easeOutCubic.transform(t)) * 2.2;
    final c = cos(ang), sn = sin(ang);
    return [
      for (final p in s.corners)
        () {
          final x = (p.longitude - s.center.longitude) * k * sx;
          final y = (p.latitude - s.center.latitude) * sy;
          return LatLng(
            s.center.latitude + (x * sn + y * c) * e,
            s.center.longitude + (x * c - y * sn) * e / k,
          );
        }(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (countdown != null) return CountdownView(countdown!);
    if (session.finished) {
      return ResultView(
        level: widget.level,
        correct: session.correct,
        points: session.points,
        avgTime: session.avgTime,
        passed: session.passed,
      );
    }
    final r = round!;
    return Scaffold(
      body: Column(
        children: [
          GameHeader(
            address: r.target,
            round: '${session.roundNo + (tapped == null ? 1 : 0)}'
                '/${GameSession.totalRounds}',
            points: session.points,
            bar: GameHeader.timeBar(
              key: session.roundNo,
              duration: widget.level.timeLimit,
              running: ready && tapped == null,
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: Level.center,
                initialZoom: widget.level.zoom,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none),
                onTap: (_, p) => _onMapTap(p),
              ),
              children: [
                TileLayer(
                  urlTemplate: widget.level.labels
                      ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                      // Esri svetla podloga: bez imena ulica, bez API ključa
                      // (Carto sada traži ključ i vraća natpis "API KEY REQUIRED")
                      : 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}',
                  maxNativeZoom: widget.level.labels ? 19 : 16,
                  // ako izvor bez imena ulica ne radi, bar prikaži običnu mapu
                  fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.rute.rute',
                  errorTileCallback: (tile, error, stack) =>
                      debugPrint('Tile greška: $error'),
                ),
                AnimatedBuilder(
                  animation: _reveal,
                  builder: (_, _) => PolygonLayer(
                    polygons: [
                      for (var i = 0; i < r.squares.length; i++)
                        Polygon(
                          points: _corners(r.squares[i], _reveal.value),
                          color: _fill(i).withValues(
                              alpha: .4 * min(1.0, _reveal.value * 2)),
                          borderColor: _fill(i).withValues(alpha: .95),
                          borderStrokeWidth: 3,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
