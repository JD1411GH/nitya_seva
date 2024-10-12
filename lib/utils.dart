// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/local_storage.dart';

class Utils {
  static final Utils _instance = Utils._internal();

  factory Utils() {
    return _instance;
  }

  Utils._internal() {
    // init
  }

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
