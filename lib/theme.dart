// Define two themes
import 'package:flutter/material.dart';

ThemeData themeDefault = ThemeData(
  brightness: Brightness.light,

  // text theme
  fontFamily: 'ConsolaMono',
  textTheme: TextTheme(
    bodySmall: TextStyle(
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
    ),
    bodyLarge: TextStyle(
      color: Colors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 24.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
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
final textColorRKC = Colors.brown;
ThemeData themeRKC = themeDefault.copyWith(
  // text theme
  textTheme: themeDefault.textTheme.copyWith(
    bodySmall: themeDefault.textTheme.bodySmall?.copyWith(
      color: textColorRKC,
    ),
    bodyMedium: themeDefault.textTheme.bodyMedium?.copyWith(
      color: textColorRKC,
    ),
    bodyLarge: themeDefault.textTheme.bodyLarge?.copyWith(
      color: textColorRKC,
    ),
    headlineMedium: themeDefault.textTheme.headlineMedium?.copyWith(
      color: textColorRKC,
    ),
  ),

  // color theme
  primaryColor: primaryColorRKC,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: primaryColorRKC,
  ),
  scaffoldBackgroundColor: variantColorRKC,

  // app bar
  appBarTheme: themeDefault.appBarTheme.copyWith(
    backgroundColor: primaryColorRKC,
  ),

  // icon theme
  iconTheme: themeDefault.iconTheme.copyWith(
    color: textColorRKC,
  ),
);

final primaryColorRRG = Colors.green;
final variantColorRRG = Colors.lightGreen[50];
final textColorRRG = Colors.green[900];
ThemeData themeRRG = themeDefault.copyWith(
  // text theme
  textTheme: themeDefault.textTheme.copyWith(
    bodySmall: themeDefault.textTheme.bodySmall?.copyWith(
      color: textColorRRG,
    ),
    bodyMedium: themeDefault.textTheme.bodyMedium?.copyWith(
      color: textColorRRG,
    ),
    bodyLarge: themeDefault.textTheme.bodyLarge?.copyWith(
      color: textColorRRG,
    ),
    headlineMedium: themeDefault.textTheme.headlineMedium?.copyWith(
      color: textColorRRG,
    ),
  ),

  // color scheme
  primaryColor: primaryColorRRG,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: primaryColorRRG,
  ),
  scaffoldBackgroundColor: variantColorRRG,

  // app bar
  appBarTheme: themeDefault.appBarTheme.copyWith(
    backgroundColor: primaryColorRRG,
  ),

  // icon theme
  iconTheme: themeDefault.iconTheme.copyWith(
    color: textColorRRG,
  ),
);
