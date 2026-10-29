import 'package:flutter/material.dart';

import 'data/progress.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await progress.load();
  runApp(const RuteApp());
}

class RuteApp extends StatelessWidget {
  const RuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rute',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      // na širokom ekranu (web) igra ostaje u "telefonskom" stubu
      builder: (context, child) => ColoredBox(
        color: C.bg,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
