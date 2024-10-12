// Define two themes
import 'package:flutter/material.dart';

final primaryColorDefault = Colors.blueGrey;
final variantColorDefault = Colors.grey[300];
final textColorDefault = Colors.black;
ThemeData themeDefault = ThemeData(
  brightness: Brightness.light,

  // text theme
  textTheme: TextTheme(
    bodySmall: TextStyle(
      color: Colors.black,
      fontSize: 12.0,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
      fontSize: 16.0,
    ),
    bodyLarge: TextStyle(
      color: Colors.black,
      fontSize: 20.0,
    ),
    headlineMedium: TextStyle(
      fontSize: 24.0,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),

  // color scheme
  primaryColor: primaryColorDefault,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: primaryColorDefault,
  ),
  scaffoldBackgroundColor: const Color.fromARGB(255, 242, 251, 255),

  // app bar
  appBarTheme: AppBarTheme(
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      fontSize: 30.0,
      color: Colors.white,
      fontFamily: 'HowdyLemon',
    ),
  ),

  // icon button theme
  iconTheme: IconThemeData(
    color: primaryColorDefault,
    size: 24.0,
  ),

  // dialog theme
  dialogTheme: DialogTheme(
    backgroundColor: Colors.grey[300],
    titleTextStyle: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    contentTextStyle: TextStyle(
      fontSize: 16.0,
      color: Colors.black,
    ),
  ),

  // input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black),
    ),
  ),

  // elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(primaryColorDefault),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 18.0,
          fontFamily: 'ConsolaMono',
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    ),
  ),

  // theme for dividor
  dividerTheme: DividerThemeData(
    color: Colors.grey[200],
    thickness: 1.0,
  ),
);

final primaryColorRKC = Colors.blue;
final variantColorRKC = Colors.blue[50];
final textColorRKC = Colors.blue[900];
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

  // dialog theme
  dialogTheme: themeDefault.dialogTheme.copyWith(
    backgroundColor: variantColorRKC,
    titleTextStyle: themeDefault.dialogTheme.titleTextStyle?.copyWith(
      color: textColorRKC,
    ),
    contentTextStyle: themeDefault.dialogTheme.contentTextStyle?.copyWith(
      color: textColorRKC,
    ),
  ),

  // input decoration theme
  inputDecorationTheme: themeDefault.inputDecorationTheme.copyWith(
    focusedBorder: themeDefault.inputDecorationTheme.focusedBorder?.copyWith(
      borderSide: BorderSide(color: textColorRKC ?? Colors.black),
    ),
    enabledBorder: themeDefault.inputDecorationTheme.enabledBorder?.copyWith(
      borderSide: BorderSide(color: textColorRKC ?? Colors.black),
    ),
  ),

  // elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(primaryColorRKC),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 18.0,
          fontFamily: 'ConsolaMono',
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    ),
  ),
);

final primaryColorRRG = Colors.brown;
final variantColorRRG = Colors.brown[50];
final textColorRRG = Colors.brown[900];
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

  // dialog theme
  dialogTheme: themeDefault.dialogTheme.copyWith(
    backgroundColor: variantColorRRG,
    titleTextStyle: themeDefault.dialogTheme.titleTextStyle?.copyWith(
      color: textColorRRG,
    ),
    contentTextStyle: themeDefault.dialogTheme.contentTextStyle?.copyWith(
      color: textColorRRG,
    ),
  ),

  // input decoration theme
  inputDecorationTheme: themeDefault.inputDecorationTheme.copyWith(
    focusedBorder: themeDefault.inputDecorationTheme.focusedBorder?.copyWith(
      borderSide: BorderSide(color: textColorRRG ?? Colors.black),
    ),
    enabledBorder: themeDefault.inputDecorationTheme.enabledBorder?.copyWith(
      borderSide: BorderSide(color: textColorRRG ?? Colors.black),
    ),
  ),

  // elevated button theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(primaryColorRRG),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      textStyle: WidgetStateProperty.all<TextStyle>(
        TextStyle(
          fontSize: 18.0,
          fontFamily: 'ConsolaMono',
        ),
      ),
      padding: WidgetStateProperty.all<EdgeInsets>(
        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
    ),
  ),
);
