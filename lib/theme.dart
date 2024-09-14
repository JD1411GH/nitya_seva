// Define two themes
import 'package:flutter/material.dart';

ThemeData themeDefault = ThemeData(
  brightness: Brightness.light,

  // text theme
  fontFamily: 'Georgia',
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      color: Colors.black54,
    ),
  ),

  // color scheme
  primaryColor: const Color(0xFF3B4043),
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)
      .copyWith(secondary: const Color.fromARGB(255, 94, 124, 148)),
);

ThemeData themeRKC = themeDefault.copyWith(
  primaryColor: Colors.deepOrange,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange)
      .copyWith(secondary: Colors.deepOrange[600]),
);

ThemeData themeRRG = themeDefault.copyWith(
  primaryColor: Colors.green,
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
      .copyWith(secondary: Colors.green[600]),
);
