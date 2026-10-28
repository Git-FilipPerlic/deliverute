import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/addresses.dart';
import '../data/progress.dart';
import '../game/level.dart';
import '../services/score_service.dart';
import '../theme.dart';
import '../widgets/countdown_view.dart';
import '../widgets/game_header.dart';
import '../widgets/result_view.dart';

enum Dir { north, east, south, west }

/// Referentna tačka: Trg slobode. Adresa se prosuđuje u odnosu na nju.
const _centre = LatLng(45.2552, 19.8451);

/// Strana sveta adrese u odnosu na centar; null ako je preblizu ili na dijagonali.
Dir? _dirOf(LatLng p) {
  final dy = (p.latitude - _centre.latitude) * 111.0; // km
  final dx = (p.longitude - _centre.longitude) * 78.6;
  final ay = dy.abs(), ax = dx.abs();
  if (max(ax, ay) < 0.5) return null;
  if (ay > ax * 1.6) return dy > 0 ? Dir.north : Dir.south;
  if (ax > ay * 1.6) return dx > 0 ? Dir.east : Dir.west;
  return null;
}

/// Bonus nivo: ispiše se adresa, a igrač dodirne strelicu strane sveta u kojoj
/// je ona u odnosu na centar. Mapa se lagano i glatko pomera (bez treperenja,
/// bez naglih promena boja — ugašeno ako sistem traži smanjene animacije).
class CompassScreen extends StatefulWidget {
  final Level level;
  const CompassScreen({super.key, required this.level});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  static const rounds = 10;
  static const feedbackTime = Duration(milliseconds: 800);

  final _map = MapController();
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 16));
  final _targets = <Address>[];
  final _times = <Duration>[];
  final stopwatch = Stopwatch();
  Timer? _timer;

  int? countdown = 3;
  int idx = 0;
  int correct = 0;
  int points = 0;
  int streak = 0;
  Dir? picked; // postavljen = prikazuje se tačno/netačno
  bool answered = false;

  Address get target => _targets[idx];
  Dir get answer => _dirOf(target.pos)!;
  bool get finished => idx >= rounds;
  Duration get avgTime => _times.isEmpty
      ? Duration.zero
      : _times.reduce((a, b) => a + b) ~/ _times.length;

  @override
  void initState() {
    super.initState();
    final pool = [
      for (final a in addresses)
        if (_dirOf(a.pos) != null) a
    ]..shuffle();
    for (var i = 0; i < rounds; i++) {
      _targets.add(pool[i % pool.length]);
    }
    _drift.addListener(_onDrift);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => countdown = countdown! - 1);
      if (countdown == 0) {
        t.cancel();
        setState(() => countdown = null);
        _begin();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _drift.dispose();
    super.dispose();
  }

  void _onDrift() {
    final t = _drift.value * 2 * pi;
    _map.move(
      LatLng(_centre.latitude + .004 * sin(t), _centre.longitude + .006 * cos(t)),
      13,
    );
  }

  void _begin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MediaQuery.of(context).disableAnimations) {
        _drift.repeat();
      }
    });
    _startRound();
  }

  void _startRound() {
    setState(() {
      picked = null;
      answered = false;
    });
    stopwatch
      ..reset()
      ..start();
    _timer = Timer(widget.level.timeLimit, () => _pick(null));
  }

  void _pick(Dir? d) {
    if (answered) return;
    _timer?.cancel();
    stopwatch.stop();
    final ok = d == answer;
    final took = d == null ? widget.level.timeLimit : stopwatch.elapsed;
    if (ok) {
      correct++;
      streak++;
      final left =
          1 - took.inMilliseconds / widget.level.timeLimit.inMilliseconds;
      points += 100 + (100 * left.clamp(0.0, 1.0)).round() + min(streak, 5) * 10;
    } else {
      streak = 0;
    }
    _times.add(took);
    setState(() {
      picked = d;
      answered = true;
    });
    _timer = Timer(feedbackTime, () {
      if (!mounted) return;
      idx++;
      if (finished) {
        _drift.stop();
        progress.record(
          level: widget.level.number,
          points: points,
          passed: correct >= Level.passMark,
        );
        ScoreService().submit(correct: correct, avgTime: avgTime);
        setState(() {});
      } else {
        _startRound();
      }
    });
  }

  Color _color(Dir d) {
    if (!answered) return C.card2;
    if (d == answer) return C.green;
    if (d == picked) return C.red;
    return C.card;
  }

  Widget _button(Dir d, IconData icon, String letter) {
    final highlight = answered && (d == answer || d == picked);
    return Padding(
      padding: const EdgeInsets.all(6),
      child: AnimatedScale(
        scale: highlight ? 1.1 : 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: _color(d),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => _pick(d),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 34),
                  Text(letter,
                      style: const TextStyle(
                          fontFamily: displayFont, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      );

  @override
  Widget build(BuildContext context) {
    if (countdown != null) return CountdownView(countdown!);
    if (finished) {
      return ResultView(
        level: widget.level,
        correct: correct,
        points: points,
        avgTime: avgTime,
        passed: correct >= Level.passMark,
      );
    }
    return Scaffold(
      body: Column(
        children: [
          GameHeader(
            address: target,
            round: '${idx + (answered ? 0 : 1)}/$rounds',
            points: points,
            bar: GameHeader.timeBar(
              key: idx,
              duration: widget.level.timeLimit,
              running: !answered,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _map,
                  options: const MapOptions(
                    initialCenter: _centre,
                    initialZoom: 13,
                    interactionOptions:
                        InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.rute.rute',
                    ),
                    MarkerLayer(markers: [
                      Marker(
                        point: _centre,
                        width: 90,
                        height: 64,
                        child: Column(
                          children: [
                            const Icon(Icons.place, color: C.red, size: 36),
                            _chip('CENTAR'),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
                Positioned(top: 8, left: 8, child: _chip('▲ S = sever')),
                if (streak >= 2)
                  Positioned(top: 8, right: 8, child: _chip('🔥 $streak')),
              ],
            ),
          ),
          Container(
            color: C.bg,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _button(Dir.north, Icons.arrow_upward, 'S'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _button(Dir.west, Icons.arrow_back, 'Z'),
                      const SizedBox(
                        width: 76,
                        child: Icon(Icons.explore, size: 40, color: C.muted),
                      ),
                      _button(Dir.east, Icons.arrow_forward, 'I'),
                    ],
                  ),
                  _button(Dir.south, Icons.arrow_downward, 'J'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
