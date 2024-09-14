// Define two themes
import 'package:flutter/material.dart';

ThemeData themeDefault = ThemeData(
  brightness: Brightness.light,

  // text theme
  fontFamily: 'JackInput',
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

  // app bar
  appBarTheme: AppBarTheme(
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 24.0,
      color: Colors.white,
      fontFamily: 'HowdyLemon',
    ),
  ),
);

final primaryColorRKC = Colors.deepOrange;
final variantColorRKC = Colors.orange[50];
ThemeData themeRKC = themeDefault.copyWith(
  primaryColor: primaryColorRKC,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: primaryColorRKC,
  ),
  scaffoldBackgroundColor: variantColorRKC,

  // app bar
  appBarTheme: themeDefault.appBarTheme.copyWith(
    backgroundColor: primaryColorRKC,
  ),
);

final primaryColorRRG = Colors.green;
final variantColorRRG = Colors.lightGreen[50];
ThemeData themeRRG = themeDefault.copyWith(
  primaryColor: primaryColorRRG,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: primaryColorRRG,
  ),
  scaffoldBackgroundColor: variantColorRRG,

  // app bar
  appBarTheme: themeDefault.appBarTheme.copyWith(
    backgroundColor: primaryColorRRG,
  ),
);
