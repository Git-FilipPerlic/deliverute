import 'package:flutter/material.dart';

import '../data/progress.dart';
import '../game/level.dart';
import 'level_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rute')),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final level in Level.all)
              Card(
                child: ListTile(
                  enabled: level.number <= progress.unlocked,
                  leading: CircleAvatar(
                    child: level.kind == LevelKind.compass
                        ? const Icon(Icons.explore)
                        : Text('${level.shownNo}'),
                  ),
                  title: Text(level.title),
                  subtitle: Text(
                    '${level.about}\n'
                    '${level.timeLimit.inMilliseconds / 1000} s po rundi'
                    '${level.labels ? '' : ' · mapa bez imena'}'
                    ' · najbolje: ${progress.bestFor(level.number)}',
                  ),
                  isThreeLine: true,
                  trailing: level.number <= progress.unlocked
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.lock),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => levelScreen(level)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
