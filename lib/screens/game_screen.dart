import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/progress.dart';
import '../game/game_session.dart';
import '../game/level.dart';
import '../services/score_service.dart';

class GameScreen extends StatefulWidget {
  final Level level;
  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const feedbackTime = Duration(milliseconds: 800);

  late final session = GameSession(widget.level);
  int? countdown = 3;
  Round? round;
  int? tapped; // -1 = isteklo vreme; dok je postavljen klikovi su blokirani
  final stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => countdown = countdown! - 1);
      if (countdown == 0) {
        t.cancel();
        setState(() => countdown = null);
        _nextRound();
      }
    });
  }

  void _nextRound() {
    setState(() {
      tapped = null;
      round = session.nextRound();
    });
    stopwatch
      ..reset()
      ..start();
    _timer = Timer(widget.level.timeLimit, () => _answer(-1));
  }

  void _answer(int i) {
    if (tapped != null) return;
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
    if (r == null || tapped != null) return;
    final i = r.squares.indexWhere((s) => s.contains(p));
    if (i != -1) _answer(i);
  }

  Color _fill(int i) {
    if (tapped == null) return Colors.teal;
    if (i == round!.correctIndex) return Colors.green;
    if (i == tapped) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (countdown != null) {
      return Scaffold(
        body: Center(
          child: Text('$countdown', style: const TextStyle(fontSize: 96)),
        ),
      );
    }
    if (session.finished) return _result(context);
    final r = round!;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Text(
          r.target.label,
          maxLines: 2,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${session.roundNo + (tapped == null ? 1 : 0)}'
                    '/${GameSession.totalRounds}'),
                Text('${session.points}'),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: tapped != null
              ? const SizedBox(height: 4)
              : TweenAnimationBuilder<double>(
                  key: ValueKey(session.roundNo),
                  tween: Tween(begin: 1, end: 0),
                  duration: widget.level.timeLimit,
                  builder: (_, v, _) => LinearProgressIndicator(value: v),
                ),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(45.2540, 19.8400),
          initialZoom: 13.5,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.none),
          onTap: (_, p) => _onMapTap(p),
        ),
        children: [
          TileLayer(
            urlTemplate: widget.level.labels
                ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.rute.rute',
          ),
          PolygonLayer(
            polygons: [
              for (var i = 0; i < r.squares.length; i++)
                Polygon(
                  points: r.squares[i].corners,
                  color: _fill(i).withValues(alpha: .4),
                  borderColor: _fill(i).withValues(alpha: .9),
                  borderStrokeWidth: 2,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _result(BuildContext context) {
    final next = widget.level.number < Level.all.length
        ? Level.all[widget.level.number]
        : null;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tačno: ${session.correct}/${GameSession.totalRounds}\n'
              'Poeni: ${session.points}\n'
              'Prosek: ${session.avgTime.inMilliseconds} ms',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 12),
            Text(session.passed
                ? (next != null
                    ? 'Prošao si! Otključan nivo ${next.number}.'
                    : 'Prošao si!')
                : 'Treba ti ${Level.passMark} tačnih za sledeći nivo.'),
            const SizedBox(height: 24),
            if (session.passed && next != null)
              FilledButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreen(level: next)),
                ),
                child: Text('Nivo ${next.number}'),
              ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => GameScreen(level: widget.level)),
              ),
              child: const Text('Opet'),
            ),
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
