import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nitya_seva/const.dart';

class Toaster {
  static final Toaster _instance = Toaster._internal();

  factory Toaster() {
    return _instance;
  }

  Toaster._internal();

  void error(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Const().colorError,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void info(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Const().colorSuccess,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
