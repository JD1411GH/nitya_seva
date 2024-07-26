// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';

class Const {
  static final Const _instance = Const._internal();

  factory Const() {
    return _instance;
  }

  Const._internal() {
    // init
  }

  String appName = 'Nitya Seva';
  String appVersion = '1.0.0';
  String dbVersion = '1';

  // theme colors
  final ColorScheme colorScheme =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043));
  final Color colorPrimary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).primary;
  final Color colorPrimaryVariant =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).primaryContainer;
  final Color colorSecondary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).secondary;
  final Color colorSecondaryVariant =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043))
          .secondaryContainer;
  final Color colorSurface =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).surface;
  final Color colorBackground =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).surface;
  final Color colorError =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).error;
  final Color colorSuccess = const Color(0xFF28A745);
  final Color colorOnPrimary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).onPrimary;
  final Color colorOnSecondary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).onSecondary;
  final Color colorOnSurface =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).onSurface;
  final Color colorOnBackground =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).onSurface;
  final Color colorOnError =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).onError;
  final Color colorOnSuccess =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).onError;
  final Color colorContrast = const Color(0xFF695F5C);
  final Color colorOnContrast = const Color(0xFF2F2928);
  final Color colorContrastSecondary = const Color(0xFF69665C);
  final Color colorOnContrastSecondary = const Color(0xFF2F2D28);
  final Color colorContrastVariant = const Color(0xFF968A86);
  final Color colorContrastSecondaryVariant = const Color(0xFF969286);
}
