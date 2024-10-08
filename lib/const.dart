// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/local_storage.dart';

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

  final List<Color> darkColors = [
    Colors.lightGreen,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.deepPurpleAccent,
    Colors.lightBlueAccent,
    Colors.indigoAccent,
    Colors.brown,
    Colors.blueGrey,
    Colors.black,
    Colors.grey,
    Colors.deepOrange,
    Colors.teal,
    Colors.cyan,
    Colors.orange,
  ];
  Color getRandomDarkColor() {
    final random = Random();
    return darkColors[random.nextInt(darkColors.length)];
  }

  final List<Color> lightColors = [
    Colors.greenAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.amberAccent,
    Colors.tealAccent,
    const Color.fromARGB(255, 153, 249, 249),
    Colors.limeAccent,
    Color.fromARGB(255, 255, 169, 169),
    const Color.fromARGB(255, 248, 139, 175),
    Color.fromARGB(255, 235, 124, 255),
  ];

  Color getRandomLightColor() {
    return lightColors[DateTime.now().millisecond % lightColors.length];
  }

  Future<String> getUserName() async {
    var u = await LS().read('user_details');
    if (u != null) {
      var uu = jsonDecode(u);
      UserDetails user = UserDetails.fromJson(uu);

      if (user.name == null) {
        return 'Username Error';
      } else {
        return user.name!;
      }
    } else {
      return 'Username Error';
    }
  }
}
