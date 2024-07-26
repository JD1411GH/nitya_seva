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

  String appName = 'Nitya Seva - ISKCON VK Hill';
  String appNameShort = 'Nitya Seva';
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
}
