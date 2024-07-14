import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RecordFirebase {
  static RecordFirebase? _instance;

  factory RecordFirebase() {
    _instance ??= RecordFirebase._();
    return _instance!;
  }

  RecordFirebase._() {
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
