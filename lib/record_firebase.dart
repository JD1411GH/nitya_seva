import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FB {
  static FB? _instance;

  factory FB() {
    _instance ??= FB._();
    return _instance!;
  }

  FB._() {
    // Code to be executed when first instantiated
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp();
  }

  Future<String> checkAccess() async {
    // returns "-", "r", "w", "rw"
    return "rw";
  }

  Future<String> checkAdminAccess() async {
    // returns "-", "r", "w", "rw"
    return "rw";
  }

  Future<void> addSevaSlot() async {
    // Add a new seva slot
  }
}
