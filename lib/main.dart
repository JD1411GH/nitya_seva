import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/loading.dart';

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
          backgroundColor: Const().colorPrimary, // Set the background color
          titleTextStyle: const TextStyle(
            color: Colors.white, // Set the text color to white for brightness
            fontSize: 28.0, // Example font size
            fontWeight: FontWeight.bold, // Example font weight
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Set the back arrow color to white
          ),
        ),
        textTheme: TextTheme(
          bodyLarge:
              TextStyle(color: Const().colorPrimary), // Set default text color
          bodyMedium:
              TextStyle(color: Const().colorPrimary), // Set default text color
          bodySmall:
              TextStyle(color: Const().colorPrimary), // Set default text color
          titleSmall: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor:
                Const().colorPrimary, // Set default text color for TextButton
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Const()
                .colorPrimary, // Set default background color for ElevatedButton
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Const()
                .colorPrimary, // Set default text color for OutlinedButton
          ),
        ),
        iconTheme: IconThemeData(
          color: Const().colorPrimary, // Set default icon color
        ),
      ),
      home: const LoadingScreen(),
      // home: const AccessDenied(),
    );
  }
}
