// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:nitya_seva/access_denied.dart';
import 'package:nitya_seva/auth.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/home.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const NityaSevaApp());
}

class NityaSevaApp extends StatelessWidget {
  const NityaSevaApp({super.key});

  Future<Widget> _getStartPage() async {
    final user = await DB().read('user');

    // checking if user has logged in before in this device
    if (user != null) {
      // checking if user has access to read and write to the database
      String? read = await DB().readCloudFromPath("access_check", 'read');
      bool? write =
          await DB().writeCloudToPath("access_check", 'write', "true");
      if (read == null || write == false) {
        return AccessDenied();
      } else {
        return HomePage();
      }
    } else {
      return LoginScreen();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 222, 150, 67)),
        useMaterial3: true,
      ),
      // home: const HomePage(title: 'VK Hill Nitya Seva'),
      home: FutureBuilder(
        future: _getStartPage(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              // Handle the case where snapshot.data is null
              return const LoginScreen(); // Fallback to LoginScreen if data is null
            }
          } else {
            // Show a loading indicator while waiting for the Future to complete
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
