import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFAA6A2D)),
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}
