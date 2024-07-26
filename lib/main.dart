import 'package:flutter/material.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/loading.dart';

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
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)),
      //   useMaterial3: true,
      // ),
      theme: ThemeData(
        primaryColor: Const().colorPrimary, // Example primary color
        appBarTheme: AppBarTheme(
          backgroundColor: Const().colorBackground, // Set the background color
          titleTextStyle: const TextStyle(
            color: Colors.white, // Set the text color to white for brightness
            fontSize: 28.0, // Example font size
            fontWeight: FontWeight.bold, // Example font weight
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Set the back arrow color to white
          ),
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}
