import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../data/addresses.dart';
import 'level.dart';

/// Pola stranice kvadrata na mapi pri sizeScale 1.0, u stepenima (~300 m).
const _baseHalfLat = 0.0027;
const _baseHalfLng = 0.0038;

/// Jedan kvadrat na mapi; centar je pomeren tako da adresa nije u sredini.
class Square {
  final Address address;
  final LatLng center;
  final double halfLat;
  final double halfLng;
  Square(this.address, this.center, this.halfLat, this.halfLng);

  List<LatLng> get corners => [
        LatLng(center.latitude - halfLat, center.longitude - halfLng),
        LatLng(center.latitude - halfLat, center.longitude + halfLng),
        LatLng(center.latitude + halfLat, center.longitude + halfLng),
        LatLng(center.latitude + halfLat, center.longitude - halfLng),
      ];

  bool contains(LatLng p) =>
      (p.latitude - center.latitude).abs() <= halfLat &&
      (p.longitude - center.longitude).abs() <= halfLng;
}

/// Jedna runda: adresa u headeru + N kvadrata, tačan je samo jedan.
class Round {
  final Address target;
  final List<Square> squares;
  final int correctIndex;
  Round(this.target, this.squares, this.correctIndex);
}

/// 10 pokušaja; broji tačne odgovore, poene i vreme reakcije.
class GameSession {
  static const totalRounds = 10;
  final Level level;
  GameSession(this.level);

  final _rng = Random();

  int roundNo = 0;
  int correct = 0;
  int points = 0;
  final List<Duration> times = [];

  bool get finished => roundNo >= totalRounds;
  bool get passed => correct >= Level.passMark;

  /// 2 pa 4 pa 6 kvadrata kako igra odmiče.
  int get squareCount => roundNo < 3 ? 2 : (roundNo < 6 ? 4 : 6);

  Round nextRound() {
    final halfLat = _baseHalfLat * level.sizeScale;
    final halfLng = _baseHalfLng * level.sizeScale;
    final pool = [...addresses]..shuffle(_rng);
    final target = pool.removeAt(0);
    if (level.nearby) {
      double d(Address a) =>
          pow(a.pos.latitude - target.pos.latitude, 2).toDouble() +
          pow(a.pos.longitude - target.pos.longitude, 2).toDouble();
      pool.sort((a, b) => d(a).compareTo(d(b)));
    }
    final picked = <Address>[target];
    for (final a in pool) {
      if (picked.length == squareCount) break;
      // kvadrati se ne smeju preklapati
      final overlaps = picked.any((p) =>
          (p.pos.latitude - a.pos.latitude).abs() < 2 * halfLat &&
          (p.pos.longitude - a.pos.longitude).abs() < 2 * halfLng);
      if (!overlaps) picked.add(a);
    }
    final squares = [
      for (final a in picked)
        Square(
          a,
          LatLng(
            a.pos.latitude + (_rng.nextDouble() - .5) * halfLat,
            a.pos.longitude + (_rng.nextDouble() - .5) * halfLng,
          ),
          halfLat,
          halfLng,
        ),
    ]..shuffle(_rng);
    return Round(
        target, squares, squares.indexWhere((s) => s.address == target));
  }

  /// Tačan odgovor: 100 poena + do 100 bonusa za brzinu.
  void answer(bool isCorrect, Duration took) {
    if (isCorrect) {
      correct++;
      final left = 1 - took.inMilliseconds / level.timeLimit.inMilliseconds;
      points += 100 + (100 * left.clamp(0.0, 1.0)).round();
    }
    times.add(took);
    roundNo++;
  }

  Duration get avgTime => times.isEmpty
      ? Duration.zero
      : times.reduce((a, b) => a + b) ~/ times.length;
}
