import 'package:flutter/material.dart';

import '../data/addresses.dart';

/// Adresa u fiksnom bloku: ulica levo (velika slova, najviše 2 reda),
/// broj desno u pločici fiksne veličine. Svaka adresa zauzima isti blok,
/// pa su svi ispisi poravnati po horizontali i vertikali.
class AddressBlock extends StatelessWidget {
  final Address address;
  const AddressBlock(this.address, {super.key});

  static const _font = 'ArchivoBlack';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            address.street.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: _font,
              fontSize: 17,
              height: 1.1,
              letterSpacing: .5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 72,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            address.number,
            style: TextStyle(
              fontFamily: _font,
              fontSize: 32,
              height: 1,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
