import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:garuda/const.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/datatypes.dart';

class FB {
  static FB? _instance;
  static Map<String, String> keyCache = {};

  StreamSubscription? _sevaSlotAddedSubscription;
  StreamSubscription? _sevaSlotChangedSubscription;
  StreamSubscription? _sevaSlotRemovedSubscription;

  StreamSubscription? _sevaTicketAddedSubscription;
  StreamSubscription? _sevaTicketChangedSubscription;
  StreamSubscription? _sevaTicketRemovedSubscription;

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
    final dbref =
        FirebaseDatabase.instance.ref("record_db${Const().dbVersion}");

    try {
      String dateTimeString = DateTime.now().toString();
      await dbref.child("test").set(dateTimeString);
      ret = "rw";
    } catch (e) {
      ret = "-";
    }

    return ret;
  }

  Future<List<SevaSlot>> readSevaSlots() async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaSlots');
    DatabaseEvent event = await dbRef.once();
    DataSnapshot snapshot = event.snapshot;
    List<SevaSlot> sevaSlots = [];

    if (snapshot.value != null) {
      sevaSlots = (snapshot.value as Map)
          .values
          .map((value) =>
              SevaSlot.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    }

    return sevaSlots;
  }

  Future<List<SevaSlot>> readSevaSlotsByDate(DateTime date) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaSlots');

    String pattern =
        date.toIso8601String().substring(0, 10); // only the date part
    Query query = dbRef.orderByKey().startAt(pattern).endAt('$pattern\uf8ff');

    DataSnapshot snapshot = await query.get();

    if (snapshot.exists) {
      return (snapshot.value as Map)
          .values
          .map((value) =>
              SevaSlot.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<SevaTicket>> readSevaTickets(DateTime timestampSlot) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');
    DatabaseReference ref =
        dbRef.child(timestampSlot.toIso8601String().replaceAll(".", "^"));

    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      return (snapshot.value as Map)
          .values
          .map((value) =>
              SevaTicket.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    } else {
      return [];
    }
  }

  // "Sat Morning": [ticket1, ticket2], "Sat Evening": [ticket3, ticket4]
  Future<Map<String, List<SevaTicket>>> readSevaTicketsByDate(
      DateTime date) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');
    final dbRefSlot = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaSlots');

    String pattern =
        date.toIso8601String().substring(0, 10); // only the date part
    Query query = dbRef.orderByKey().startAt(pattern).endAt('$pattern\uf8ff');

    DataSnapshot snapshot = await query.get();

    Map<String, List<SevaTicket>> sevaTickets =
        {}; // "Sat Morning": [ticket1, ticket2], "Sat Evening": [ticket3, ticket4]
    if (snapshot.exists) {
      var mapSlotsFiltered = snapshot.value as Map;
      for (var entry in mapSlotsFiltered.entries) {
        var key = entry.key;
        var value = entry.value;

        // find the seva slot title for the given key
        DatabaseReference ref = dbRefSlot.child(key);
        DataSnapshot snapshotSlot = await ref.get();
        String title = '';
        if (snapshotSlot.value != null) {
          var slotValue = snapshotSlot.value as Map<dynamic, dynamic>;
          if (slotValue.containsKey('title')) {
            title = slotValue['title'];
          }
        }
        if (title.isEmpty) {
          Toaster().error("Unable to find title for slot");
        } else {
          sevaTickets[title] = [];
        }

        var mapTickets = value as Map;
        mapTickets.forEach((ticketKey, ticketValue) {
          SevaTicket ticket = SevaTicket.fromJson(
              Map<String, dynamic>.from(ticketValue as Map));
          sevaTickets[title]!.add(ticket);
        });
      }

      return sevaTickets;
    } else {
      return {};
    }
  }

  Future<String> checkAdminAccess() async {
    // returns "-", "r", "rw"
    return "-";
  }

  Future<void> addSevaSlot(
      String timestampSlot, Map<String, dynamic> sevaSlot) async {
    // Add a new seva slot
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}');
    DatabaseReference ref =
        dbRef.child('sevaSlots').child(timestampSlot.replaceAll(".", "^"));
    await ref.set(sevaSlot);
  }

  Future<void> removeSevaSlot(String timestampSlot) async {
    // Remove a seva slot
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}');
    DatabaseReference ref =
        dbRef.child('sevaSlots').child(timestampSlot.replaceAll(".", "^"));
    await ref.remove();
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

  Future<void> addSevaTicket(String timestampSlot, String timestampTicket,
      Map<String, dynamic> ticket) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    if (timestampSlot.isEmpty) {
      Toaster().error("Unable to add to database");
    } else {
      DatabaseReference ref = dbRef
          .child(timestampSlot.replaceAll(".", "^"))
          .child(timestampTicket.replaceAll(".", "^"));
      await ref.set(ticket);
    }
  }

  Future<void> removeSevaTicket(
      String timestampSlot, String timestampTicket) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    DatabaseReference ref = dbRef
        .child(timestampSlot.replaceAll(".", "^"))
        .child(timestampTicket.replaceAll(".", "^"));
    await ref.remove();
  }

  Future<void> updateSevaTicket(String timestampSlot, String timestampTicket,
      Map<String, dynamic> json) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    DatabaseReference ref = dbRef
        .child(timestampSlot.replaceAll(".", "^"))
        .child(timestampTicket.replaceAll(".", "^"));
    await ref.set(json);
  }

  Future<void> listenForSevaSlotChange(FBCallbacks callbacks) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaSlots');

    _sevaSlotAddedSubscription = dbRef.onChildAdded.listen((event) {
      callbacks.onChange("ADD_SEVA_SLOT", event.snapshot.value);
    });

    _sevaSlotChangedSubscription = dbRef.onChildChanged.listen((event) {
      callbacks.onChange("UPDATE_SEVA_SLOT", event.snapshot.value);
    });

    _sevaSlotRemovedSubscription = dbRef.onChildRemoved.listen((event) {
      callbacks.onChange("REMOVE_SEVA_SLOT", event.snapshot.value);
    });
  }

  Future<void> listenForSevaTicketChange(FBCallbacks callbacks) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    _sevaTicketAddedSubscription = dbRef.onChildAdded.listen((event) {
      callbacks.onChange("ADD_SEVA_TICKET", event.snapshot.value);
    });

    _sevaTicketChangedSubscription = dbRef.onChildChanged.listen((event) {
      callbacks.onChange("UPDATE_SEVA_TICKET", event.snapshot.value);
    });

    _sevaTicketRemovedSubscription = dbRef.onChildRemoved.listen((event) {
      callbacks.onChange("REMOVE_SEVA_TICKET", event.snapshot.value);
    });
  }

  Future<void> removeSevaSlotListeners() async {
    await _sevaSlotAddedSubscription?.cancel();
    await _sevaSlotChangedSubscription?.cancel();
    await _sevaSlotRemovedSubscription?.cancel();
  }

  Future<void> removeSevaTicketListeners() async {
    await _sevaTicketAddedSubscription?.cancel();
    await _sevaTicketChangedSubscription?.cancel();
    await _sevaTicketRemovedSubscription?.cancel();
  }

  Future<void> addUpdateTallyCash(
      DateTime timestampSlot, Map<String, int> cash) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/tallyCash');

    String key = timestampSlot.toIso8601String().replaceAll(".", "^");

    DatabaseReference ref = dbRef.child(key);
    await ref.set(cash);
    Toaster().info("Saved successfully");
  }

  Future<Map<String, int>> readTallyCash(DateTime timestampSlot) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/tallyCash');

    String key = timestampSlot.toIso8601String().replaceAll(".", "^");

    DataSnapshot snapshot = await dbRef.child(key).get();
    Map<String, int> cash = {};

    if (snapshot.exists) {
      cash = Map<String, int>.from(snapshot.value as Map);
    }

    return cash;
  }

  Future<void> addUpdateTallyUpi(
      DateTime timestampSlot, Map<String, int> json) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/tallyUpiCard');

    String key = timestampSlot.toIso8601String().replaceAll(".", "^");

    DatabaseReference ref = dbRef.child(key);
    await ref.set(json);
    Toaster().info("Saved successfully");
  }

  Future<Map<String, int>> readTallyUpi(DateTime timestampSlot) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/tallyUpiCard');

    String key = timestampSlot.toIso8601String().replaceAll(".", "^");

    DataSnapshot snapshot = await dbRef.child(key).get();
    Map<String, int> json = {};

    if (snapshot.exists) {
      json = Map<String, int>.from(snapshot.value as Map);
    }

    return json;
  }
}

class FBCallbacks {
  void Function(String changeType, dynamic data) onChange;

  FBCallbacks({
    required this.onChange,
  });
}
