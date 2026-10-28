import 'package:flutter/material.dart';

/// Boje u iOS maniru: tamna podloga, kartice sa zaobljenim ivicama,
/// sistemske boje za tačno/netačno, jedan topao akcenat za broj adrese.
class C {
  static const bg = Color(0xFF0A0A0F);
  static const card = Color(0xFF1C1C1E);
  static const card2 = Color(0xFF2C2C2E);
  static const accent = Color(0xFFFFD60A); // broj adrese
  static const teal = Color(0xFF40C8E0); // kvadrati, akcenti
  static const green = Color(0xFF30D158);
  static const red = Color(0xFFFF453A);
  static const muted = Color(0xFF8E8E93);
}

const displayFont = 'ArchivoBlack';

ThemeData appTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: C.teal,
        brightness: Brightness.dark,
      ).copyWith(surface: C.card, primary: C.teal),
    );
