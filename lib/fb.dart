import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

typedef JsonMapSevaSlot = Map<String, dynamic>;

class FB {
  static FB? _instance;

  factory FB() {
    _instance ??= FB._();
    return _instance!;
  }

  FB._() {
    // Code to be executed when first instantiated
  }

  // returns "-", "r", "rw"
  Future<String> checkAccess() async {
    String ret = "-";
    final dbref = FirebaseDatabase.instance.ref("record");

    try {
      String dateTimeString = DateTime.now().toString();
      await dbref.child("test").set(dateTimeString);
      ret = "rw";
    } catch (e) {
      ret = "-";
    }

    return ret;
  }

  Future<List<dynamic>> readSevaSlots() async {
    final dbRef = FirebaseDatabase.instance.ref('record/sevaSlots');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;
    List<dynamic> sevaSlots = [];

    if (snapshot.value != null) {
      sevaSlots = (snapshot.value as Map).values.toList();
    }

    return sevaSlots;
  }

  Future<String> checkAdminAccess() async {
    // returns "-", "r", "rw"
    return "-";
  }

  Future<void> addSevaSlot(Map<String, dynamic> _sevaSlot) async {
    // Add a new seva slot
    final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('record');
    DatabaseReference ref = _dbRef.child('sevaSlots').push();
    await ref.set(_sevaSlot);
  }
}
