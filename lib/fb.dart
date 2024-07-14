import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:nitya_seva/toaster.dart';

class FB {
  static FB? _instance;
  static Map<String, String> keyCache = {};

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

      for (var slot in sevaSlots) {
        if (slot['sevaTickets'] != null) {
          slot['sevaTickets'] = (slot['sevaTickets'] as Map).values.toList();
        } else {
          slot['sevaTickets'] = [];
        }
      }
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

  Future<String> _getSelectedSlotKey(
      DatabaseReference dbRef, String timestamp) async {
    if (keyCache.containsKey(timestamp)) {
      return keyCache[timestamp]!;
    }

    String ret = '';
    DataSnapshot snapshot = await dbRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> entries =
          Map<String, dynamic>.from(snapshot.value as Map);
      entries.forEach((key, value) {
        if (value['timestamp'] == timestamp) {
          ret = key;
          keyCache[timestamp] = key;
        }
      });
    }
    return ret;
  }

  Future<void> addSevaTicket(
      String selectedSlot, Map<String, dynamic> ticket) async {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record/sevaSlots');

    String selectedSlotKey = await _getSelectedSlotKey(dbRef, selectedSlot);
    if (selectedSlotKey.isEmpty) {
      Toaster().error("Unable to add to database");
    } else {
      DatabaseReference ref = dbRef.child(selectedSlotKey).child("sevaTickets");
      await ref.push().set(ticket);
    }
  }
}
