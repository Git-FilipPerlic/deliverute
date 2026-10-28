import 'package:flutter/material.dart';

import '../game/level.dart';
import 'compass_screen.dart';
import 'game_screen.dart';

/// Ekran koji odgovara vrsti nivoa (mapa sa kvadratima ili bonus kompas).
Widget levelScreen(Level l) => l.kind == LevelKind.compass
    ? CompassScreen(level: l)
    : GameScreen(level: l);
