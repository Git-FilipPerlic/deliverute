import 'package:latlong2/latlong.dart';

/// Adresa + približne koordinate u Novom Sadu.
/// NAPOMENA: koordinate su ručno procenjene, treba ih proveriti/zameniti
/// pravim geokodiranjem (vidi PLAN.md, faza 2).
class Address {
  final String label;
  final LatLng pos;
  const Address(this.label, this.pos);
}

const addresses = <Address>[
  Address('Zmaj Jovina 5', LatLng(45.2554, 19.8446)),
  Address('Dunavska 8', LatLng(45.2570, 19.8470)),
  Address('Bulevar oslobođenja 12', LatLng(45.2600, 19.8335)),
  Address('Bulevar Jaše Tomića 5', LatLng(45.2640, 19.8370)),
  Address('Kisačka 44', LatLng(45.2650, 19.8410)),
  Address('Temerinska 3', LatLng(45.2655, 19.8520)),
  Address('Sentandrejski put 10', LatLng(45.2700, 19.8480)),
  Address('Futoška 30', LatLng(45.2460, 19.8380)),
  Address('Narodnog fronta 21', LatLng(45.2410, 19.8340)),
  Address('Vojvode Putnika 2', LatLng(45.2430, 19.8440)),
  Address('Radnička 20', LatLng(45.2495, 19.8500)),
  Address('Bulevar Mihajla Pupina 16', LatLng(45.2518, 19.8440)),
  Address('Bulevar cara Lazara 3', LatLng(45.2480, 19.8280)),
];
