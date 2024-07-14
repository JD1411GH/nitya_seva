import 'package:flutter/material.dart';
import 'package:nitya_seva/const.dart';

Future<void> main() async {
  runApp(const NityaSevaApp());
}

class NityaSevaApp extends StatelessWidget {
  const NityaSevaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Const().appName,
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 222, 150, 67)),
        useMaterial3: true,
      ),
      home: Text(Const().appName),
    );
  }
}
