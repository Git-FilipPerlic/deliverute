import 'package:latlong2/latlong.dart';

/// Ulica + broj + približne koordinate u Novom Sadu.
/// NAPOMENA: koordinate su ručno procenjene (placeholder), treba ih zameniti
/// pravim podacima (vidi PLAN.md).
class Address {
  final String street;
  final String number;
  final LatLng pos;
  const Address(this.street, this.number, this.pos);

  String get label => '$street $number';
}

const addresses = <Address>[
  Address('Zmaj Jovina', '5', LatLng(45.2554, 19.8446)),
  Address('Trg slobode', '2', LatLng(45.2552, 19.8451)),
  Address('Dunavska', '8', LatLng(45.2570, 19.8470)),
  Address('Jevrejska', '12', LatLng(45.2548, 19.8433)),
  Address('Cara Dušana', '20', LatLng(45.2590, 19.8470)),
  Address('Njegoševa', '10', LatLng(45.2625, 19.8395)),
  Address('Bulevar oslobođenja', '12', LatLng(45.2600, 19.8335)),
  Address('Bulevar oslobođenja', '60', LatLng(45.2560, 19.8300)),
  Address('Bulevar Jaše Tomića', '5', LatLng(45.2640, 19.8370)),
  Address('Bulevar Jaše Tomića', '22', LatLng(45.2655, 19.8400)),
  Address('Kisačka', '44', LatLng(45.2650, 19.8410)),
  Address('Temerinska', '3', LatLng(45.2655, 19.8520)),
  Address('Temerinska', '40', LatLng(45.2690, 19.8560)),
  Address('Sentandrejski put', '10', LatLng(45.2700, 19.8480)),
  Address('Futoška', '30', LatLng(45.2460, 19.8380)),
  Address('Futoška', '75', LatLng(45.2400, 19.8250)),
  Address('Narodnog fronta', '21', LatLng(45.2410, 19.8340)),
  Address('Narodnog fronta', '70', LatLng(45.2380, 19.8250)),
  Address('Vojvode Putnika', '2', LatLng(45.2430, 19.8440)),
  Address('Radnička', '20', LatLng(45.2495, 19.8500)),
  Address('Šumadijska', '4', LatLng(45.2480, 19.8470)),
  Address('Gogoljeva', '10', LatLng(45.2470, 19.8420)),
  Address('Bulevar Mihajla Pupina', '16', LatLng(45.2518, 19.8440)),
  Address('Bulevar cara Lazara', '3', LatLng(45.2480, 19.8280)),
  Address('Bulevar cara Lazara', '50', LatLng(45.2440, 19.8200)),
  Address('Bulevar Evrope', '10', LatLng(45.2470, 19.8240)),
  Address('Heroja Pinkija', '6', LatLng(45.2430, 19.8300)),
  Address('Alekse Šantića', '15', LatLng(45.2490, 19.8330)),
  // gušće u centru, za zumirane nivoe
  Address('Svetozara Miletića', '12', LatLng(45.2575, 19.8440)),
  Address('Pašićeva', '6', LatLng(45.2535, 19.8460)),
  Address('Sutjeska', '2', LatLng(45.2510, 19.8420)),
  Address('Stražilovska', '10', LatLng(45.2580, 19.8380)),
  Address('Vase Stajića', '8', LatLng(45.2520, 19.8370)),
  Address('Maksima Gorkog', '5', LatLng(45.2550, 19.8350)),
  Address('Zmaj Jovina', '18', LatLng(45.2557, 19.8420)),
  Address('Dunavska', '22', LatLng(45.2585, 19.8490)),
];
