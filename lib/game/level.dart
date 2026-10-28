import 'dart:math';

import 'package:latlong2/latlong.dart';

enum LevelKind { address, compass }

/// Težina igre. Svaki nivo je teži od prethodnog: manji kvadrati, manje
/// vremena, susedni (zbunjujući) kvadrati, mapa bez imena ulica i sve veći zoom.
class Level {
  final int number; // redni broj u listi (čuva se u napretku)
  final String title;
  final LevelKind kind;
  final double zoom;
  final double sizeScale; // 1.0 = ~600 m stranica kvadrata
  final Duration timeLimit; // po rundi; istek vremena = netačno
  final bool labels; // imena ulica na mapi
  final bool nearby; // kvadrati se biraju blizu tačnog
  final String about; // žena po kojoj je nivo nazvan
  const Level(
    this.number,
    this.title,
    this.sizeScale,
    this.timeLimit, {
    this.zoom = 13.5,
    this.labels = true,
    this.nearby = false,
    this.kind = LevelKind.address,
    this.about = '',
  });

  /// Tačnih odgovora (od 10) potrebno za otključavanje sledećeg nivoa.
  static const passMark = 7;

  /// Redni broj bez bonus nivoa (Xenia = nivo 8).
  int get shownNo =>
      number - all.where((l) => l.kind == LevelKind.compass && l.number < number).length;

  static const center = LatLng(45.2540, 19.8400);

  /// Da li je tačka vidljiva na mapi pri ovom zoomu (sa marginom).
  bool inView(LatLng p) {
    final k = pow(2, 13.5 - zoom).toDouble() * .8;
    return (p.latitude - center.latitude).abs() < 0.0256 * k &&
        (p.longitude - center.longitude).abs() < 0.0242 * k;
  }

  static const all = <Level>[
    Level(1, 'Isidora', 1.0, Duration(seconds: 10),
        about: 'Isidora Sekulić · književnica, gimnazija u NS'),
    Level(2, 'Mileva', 0.8, Duration(seconds: 7),
        about: 'Mileva Marić · naučnica'),
    Level(3, 'Milica', 0.8, Duration(seconds: 5),
        nearby: true, about: 'Milica Stojadinović Srpkinja · pesnikinja'),
    Level(4, 'Savka', 0.6, Duration(seconds: 4),
        labels: false, nearby: true, about: 'Savka Subotić · humanitarka'),
    Level(5, 'Marija', 0.5, Duration(seconds: 3),
        labels: false, nearby: true, about: 'Marija Trandafil · dobrotvorka'),
    Level(6, 'Draga', 1.0, Duration(seconds: 4),
        kind: LevelKind.compass,
        about: 'Bonus · strane sveta · Draga Dejanović, mislilja'),
    Level(7, 'Mara', 0.45, Duration(seconds: 3),
        zoom: 14,
        labels: false,
        nearby: true,
        about: 'Mara Bogdanović Rosandić · slikarka, fotografkinja'),
    Level(8, 'Mira', 0.35, Duration(seconds: 3),
        zoom: 14.5,
        labels: false,
        nearby: true,
        about: 'Mira Banjac · glumica'),
    Level(9, 'Xenia', 0.3, Duration(milliseconds: 2500),
        zoom: 14.5, labels: false, nearby: true, about: 'Nivo 8'),
    Level(10, 'Nataša', 0.25, Duration(milliseconds: 2500),
        zoom: 15,
        labels: false,
        nearby: true,
        about: 'Nataša Bekvalac · pevačica'),
    Level(11, 'Julijana', 0.2, Duration(seconds: 2),
        zoom: 15,
        labels: false,
        nearby: true,
        about: 'Julijana Ilijić · borkinja za ženska prava'),
  ];
}
