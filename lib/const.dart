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

  String appName = 'Garuda';
  String appVersion = '1.0.0';
  String dbVersion = '1';

  List<int> ticketAmounts = [400, 500, 1000, 2500];

  // theme colors
  final Color colorPrimary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).primary;
  final color400 = Colors.blue[200];
  final color400variant = Colors.blue[900];
  final color500 = Colors.yellow[200];
  final color500variant = Colors.yellow[900];
  final color1000 = Colors.green[200];
  final color1000variant = Colors.green[900];
  final color2500 = Colors.pink[200];
  final color2500variant = Colors.pink[900];
}
