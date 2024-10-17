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

  DateTime morningCutoff = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 14, 0);

  List<Map<String, int>> pushpanjaliTickets = [
    {'amount': 400, 'ladduPacks': 1},
    {'amount': 500, 'ladduPacks': 1},
    {'amount': 1000, 'ladduPacks': 2},
    {'amount': 2500, 'ladduPacks': 3},
  ];

  List<Map<String, dynamic>> otherSevaTickets = [
    {
      'name': "Special Puja",
      'amount': 0,
      'ladduPacks': 1,
      'color': Colors.pink[900]
    },
    {
      'name': "Festival",
      'amount': 500,
      'ladduPacks': 2,
      'color': Colors.indigo[900]
    },
  ];

  Map<String, dynamic> deepotsava = {
    'lamp': {
      'cost': 5,
    },
    'plate': {
      'cost': 10,
    },
  };

  // theme ticketColors
  final Color colorPrimary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).primary;
  final ticketColors = {
    '400': Colors.blue[300],
    '400variant': Colors.blue[900],
    '500': Colors.yellow[600],
    '500variant': Colors.yellow[900],
    '1000': Colors.green[300],
    '1000variant': Colors.green[900],
    '2500': Colors.pink[200],
    '2500variant': Colors.pink[900],
  };

  // payment modes
  final paymentModes = {
    'UPI': {'icon': "assets/images/icon_upi.png", 'color': Colors.orange},
    'Cash': {'icon': "assets/images/icon_cash.png", 'color': Colors.green},
    'Card': {'icon': "assets/images/icon_card.png", 'color': Colors.blue},
    'Gift': {'icon': "assets/images/icon_gratis.png", 'color': Colors.purple},
  };
}
