import 'package:flutter/material.dart';

import '../data/addresses.dart';
import '../theme.dart';

/// Adresa u fiksnom bloku: ulica levo (bela, velika slova, najviše 2 reda),
/// tanak razdelnik, pa broj u žutoj pločici fiksne visine. Ulica i broj su
/// jasno odvojeni, a svaka adresa zauzima isti blok.
class AddressBlock extends StatelessWidget {
  final Address address;
  const AddressBlock(this.address, {super.key});

  /// Duže nazive lomi na dva reda po sredini.
  static String _twoLines(String s) {
    final words = s.split(' ');
    if (s.length <= 13 || words.length < 2) return s;
    var best = 1, bestDiff = 1 << 30;
    for (var i = 1; i < words.length; i++) {
      final a = words.sublist(0, i).join(' ').length;
      final b = words.sublist(i).join(' ').length;
      if ((a - b).abs() < bestDiff) {
        bestDiff = (a - b).abs();
        best = i;
      }
    }
    return '${words.sublist(0, best).join(' ')}\n${words.sublist(best).join(' ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _twoLines(address.street.toUpperCase()),
              style: const TextStyle(
                fontFamily: displayFont,
                fontSize: 22,
                height: 1.15,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: 44,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 70),
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: C.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            address.number,
            style: const TextStyle(
              fontFamily: displayFont,
              fontSize: 38,
              height: 1,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
