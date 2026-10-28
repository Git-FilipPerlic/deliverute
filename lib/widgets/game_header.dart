import 'package:flutter/material.dart';

import '../data/addresses.dart';
import '../theme.dart';
import 'address_block.dart';

/// Gornji deo igre: nazad, adresa (ulica | broj), runda + poeni, traka vremena.
class GameHeader extends StatelessWidget {
  final Address address;
  final String round;
  final int points;
  final Widget bar;
  const GameHeader({
    super.key,
    required this.address,
    required this.round,
    required this.points,
    required this.bar,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.card,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 32),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(child: AddressBlock(address)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(round,
                          style: const TextStyle(color: C.muted, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('$points',
                          style: const TextStyle(
                              fontFamily: displayFont, fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 4, child: bar),
          ],
        ),
      ),
    );
  }

  /// Traka vremena: puna dok traje otkrivanje, pa se prazni.
  static Widget timeBar({
    required Object key,
    required Duration duration,
    required bool running,
  }) {
    if (!running) {
      return const LinearProgressIndicator(
          value: 1, color: C.teal, backgroundColor: C.card2);
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey(key),
      tween: Tween(begin: 1, end: 0),
      duration: duration,
      builder: (_, v, _) => LinearProgressIndicator(
          value: v, color: C.teal, backgroundColor: C.card2),
    );
  }
}
