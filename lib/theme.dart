// Define two themes
import 'package:flutter/material.dart';

ThemeData themeDefault = ThemeData(
  brightness: Brightness.light,

  // text theme
  fontFamily: 'Georgia',
  textTheme: TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black,
    ),
  ),

  // color scheme
  primaryColor: Colors.blueGrey,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blueGrey,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 242, 251, 255),
);

ThemeData themeRKC = themeDefault.copyWith(
  primaryColor: Colors.deepOrange,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.deepOrange,
  ),
  scaffoldBackgroundColor: Colors.orange[50],
);

ThemeData themeRRG = themeDefault.copyWith(
  primaryColor: Colors.green,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.green,
  ),
  scaffoldBackgroundColor: Colors.lightGreen[50],
);
