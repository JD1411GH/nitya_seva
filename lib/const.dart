// ignore_for_file: unused_local_variable

import 'dart:convert';

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

  List<int> ticketAmounts = [400, 500, 1000, 2500];

  // theme ticketColors
  final Color colorPrimary =
      ColorScheme.fromSeed(seedColor: const Color(0xFF3B4043)).primary;
  final ticketColors = {
    '400': Colors.blue[200],
    '400variant': Colors.blue[900],
    '500': Colors.yellow[200],
    '500variant': Colors.yellow[900],
    '1000': Colors.green[200],
    '1000variant': Colors.green[900],
    '2500': Colors.pink[200],
    '2500variant': Colors.pink[900],
  };

  final List<Color> darkColors = [
    Colors.orange,
    Colors.lightGreen,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.deepPurpleAccent,
    Colors.lightBlueAccent,
    Colors.deepOrangeAccent,
    Colors.indigoAccent,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  Color getRandomDarkColor() {
    return darkColors[DateTime.now().millisecond % darkColors.length];
  }

  final List<Color> lightColors = [
    Colors.greenAccent,
    Colors.lightBlueAccent,
    Colors.lightGreenAccent,
    Colors.amberAccent,
    Colors.tealAccent,
    Colors.cyanAccent,
    Colors.limeAccent,
    Colors.orangeAccent,
    Colors.redAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
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
