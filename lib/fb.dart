import 'package:firebase_database/firebase_database.dart';
import 'package:garuda/const.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/datatypes.dart';

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

  Future<List<SevaTicket>> readSevaTicketsByDate(DateTime date) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    String pattern =
        date.toIso8601String().substring(0, 10); // only the date part
    Query query = dbRef.orderByKey().startAt(pattern).endAt('$pattern\uf8ff');

    DataSnapshot snapshot = await query.get();

    if (snapshot.exists) {
      Object? timestampSlotKey = snapshot.value;
      if (timestampSlotKey != null) {
        // dynamic listEntries = timestampSlotKey;
      }

      return [];
    } else {
      return [];
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

    dbRef.onChildAdded.listen((event) {
      callbacks.onChange("ADD_SEVA_SLOT", event.snapshot.value);
    });

    dbRef.onChildChanged.listen((event) {
      callbacks.onChange("UPDATE_SEVA_SLOT", event.snapshot.value);
    });

    dbRef.onChildRemoved.listen((event) {
      callbacks.onChange("REMOVE_SEVA_SLOT", event.snapshot.value);
    });
  }

  Future<void> listenForSevaTicketChange(FBCallbacks callbacks) async {
    final dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    dbRef.onChildAdded.listen((event) {
      callbacks.onChange("ADD_SEVA_TICKET", event.snapshot.value);
    });

    dbRef.onChildChanged.listen((event) {
      callbacks.onChange("UPDATE_SEVA_TICKET", event.snapshot.value);
    });

    dbRef.onChildRemoved.listen((event) {
      callbacks.onChange("REMOVE_SEVA_TICKET", event.snapshot.value);
    });
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
