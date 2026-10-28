/// Težina igre. Svaki nivo je teži od prethodnog: manji kvadrati, manje
/// vremena, susedni (zbunjujući) kvadrati i na kraju mapa bez imena ulica.
class Level {
  final int number;
  final double sizeScale; // 1.0 = ~600 m stranica kvadrata
  final Duration timeLimit; // po rundi; istek vremena = netačno
  final bool labels; // imena ulica na mapi
  final bool nearby; // kvadrati se biraju blizu tačnog
  const Level(this.number, this.sizeScale, this.timeLimit,
      {this.labels = true, this.nearby = false});

  /// Tačnih odgovora (od 10) potrebno za otključavanje sledećeg nivoa.
  static const passMark = 7;

  static const all = <Level>[
    Level(1, 1.0, Duration(seconds: 10)),
    Level(2, 0.8, Duration(seconds: 7)),
    Level(3, 0.8, Duration(seconds: 5), nearby: true),
    Level(4, 0.6, Duration(seconds: 4), labels: false, nearby: true),
    Level(5, 0.5, Duration(seconds: 3), labels: false, nearby: true),
  ];
}
