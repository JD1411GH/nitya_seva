import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:garuda/const.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';
import 'package:garuda/admin/user.dart';

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
          continue;
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

  Future<void> addSevaSlot(
      DateTime timestampSlot, Map<String, dynamic> sevaSlot) async {
    // Add a new seva slot
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}');
    DatabaseReference ref = dbRef
        .child('sevaSlots')
        .child(timestampSlot.toIso8601String().replaceAll(".", "^"));
    await ref.set(sevaSlot);
  }

  Future<void> deleteSevaSlot(DateTime timestampSlot) async {
    for (String key in [
      'sevaSlots',
      'sevaTickets',
      'tallyCash',
      'tallyUpiCard'
    ]) {
      final DatabaseReference dbRef =
          FirebaseDatabase.instance.ref('record_db${Const().dbVersion}');
      DatabaseReference ref = dbRef
          .child(key)
          .child(timestampSlot.toIso8601String().replaceAll(".", "^"));
      await ref.remove();
    }
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

  Future<void> deleteSevaTicket(
      String timestampSlot, String timestampTicket) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaTickets');

    DatabaseReference ref = dbRef
        .child(timestampSlot.replaceAll(".", "^"))
        .child(timestampTicket.replaceAll(".", "^"));
    await ref.remove();
  }

  Future<void> editSevaTicket(String timestampSlot, String timestampTicket,
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

  Future<void> listenForChange(String path, FBCallbacks callbacks) async {
    final dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}/$path');

    _sevaTicketAddedSubscription = dbRef.onChildAdded.listen((event) {
      callbacks.onChange("ADD", event.snapshot.value);
    });

    _sevaTicketChangedSubscription = dbRef.onChildChanged.listen((event) {
      callbacks.onChange("UPDATE", event.snapshot.value);
    });

    _sevaTicketRemovedSubscription = dbRef.onChildRemoved.listen((event) {
      callbacks.onChange("REMOVE", event.snapshot.value);
    });
  }

  Future<void> deleteSevaSlotListeners() async {
    await _sevaSlotAddedSubscription?.cancel();
    await _sevaSlotChangedSubscription?.cancel();
    await _sevaSlotRemovedSubscription?.cancel();
  }

  Future<void> deleteSevaTicketListeners() async {
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

  Future<void> addPendingUser(UserDetails user) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/users/pending');

    if (user.uid != null) {
      DatabaseReference ref = dbRef.child(user.uid!);
      try {
        await ref.set(user.toJson());
      } catch (e) {
        // Handle the error here
        Toaster().error('Database write error: $e');
      }
    }
  }

  // returns success or failure
  Future<bool> approveUser(UserDetails user) async {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}/users');

    if (user.uid != null) {
      DatabaseReference refPending = dbRef.child('pending').child(user.uid!);
      DatabaseReference refApproved = dbRef.child('approved').child(user.uid!);

      DataSnapshot snapshot = await refPending.get();
      if (snapshot.exists) {
        try {
          await refApproved.set(user.toJson());
          await refPending.remove();
        } catch (e) {
          // Handle the error here
          Toaster().error('Database write error: $e');
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }

    return true;
  }

  Future<void> rejectUser(UserDetails user) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/users/pending');

    if (user.uid != null) {
      DatabaseReference ref = dbRef.child(user.uid!);
      await ref.remove();
    }
  }

  // returns "pending", "approved", "none"
  Future<String> checkUserApprovalStatus(UserDetails user) async {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}/users');

    if (user.uid != null) {
      DatabaseReference ref = dbRef.child('pending').child(user.uid!);
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        // User is pending approval
        return "pending";
      }

      ref = dbRef.child('approved').child(user.uid!);
      snapshot = await ref.get();
      if (snapshot.exists) {
        // User is approved
        return "approved";
      }
    }

    return "none";
  }

  Future<String> getUserRole(String uid) async {
    final DatabaseReference dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}/users');

    DatabaseReference ref = dbRef.child('approved').child(uid);
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      if (snapshot.value != null) {
        Map map = snapshot.value as Map;
        return map['role'];
      } else {
        return "none";
      }
    } else {
      return "none";
    }
  }

  Future<void> editSlot(DateTime timestampSlot, String title) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/sevaSlots');

    String key = timestampSlot.toIso8601String().replaceAll(".", "^");

    DatabaseReference ref = dbRef.child(key);
    await ref.update({'title': title});
  }

  Future<UserDetails> getUserDetails(String uid) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/users/approved');

    DataSnapshot snapshot = await dbRef.child(uid).get();
    UserDetails user = UserDetails();

    if (snapshot.exists) {
      user = UserDetails.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map));
    }

    return user;
  }

  Future<DateTime> readLatestLadduSession() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva');

    DateTime endDate = DateTime.now();
    DateTime startDate = endDate.subtract(Duration(days: 30));

    final Query query = dbRef
        .orderByKey()
        .startAt(startDate.toIso8601String().replaceAll(".", "^"))
        .endAt(endDate.toIso8601String().replaceAll(".", "^"));

    final DataSnapshot snapshot = await query.get();
    if (snapshot.exists) {
      var allotments = snapshot.value as Map;
      var keys = allotments.keys.toList();
      keys.sort();
      var lastKey = keys.last;

      lastKey = lastKey.replaceAll("^", ".");
      return DateTime.parse(lastKey);
    } else {
      return DateTime.now();
    }
  }

  Future<List<DateTime>> readLadduSessions(
      DateTime startDate, DateTime endDate) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva');

    final Query query = dbRef
        .orderByKey()
        .startAt(startDate.toIso8601String().replaceAll(".", "^"))
        .endAt(endDate.toIso8601String().replaceAll(".", "^"));

    final DataSnapshot snapshot = await query.get();
    if (snapshot.exists) {
      var allotments = snapshot.value as Map;
      var keys = allotments.keys.toList();
      keys.sort();
      return keys
          .map((key) => DateTime.parse(key.replaceAll("^", ".")))
          .toList();
    } else {
      return [];
    }
  }

  Future<LadduReturn> readLadduReturnStatus(DateTime session) {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a/returned');

    return dbRef.get().then((snapshot) {
      if (snapshot.exists) {
        return LadduReturn.fromJson(
            Map<String, dynamic>.from(snapshot.value as Map));
      } else {
        return LadduReturn(
            timestamp: DateTime.now(), to: '', count: -1, user: 'Unknown');
      }
    });
  }

  Future<List<UserDetails>> readPendingUsers() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/users/pending');

    DataSnapshot snapshot = await dbRef.get();
    List<UserDetails> users = [];

    if (snapshot.exists) {
      users = (snapshot.value as Map)
          .values
          .map((value) =>
              UserDetails.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    }

    return users;
  }

  Future<List<UserDetails>> readApprovedUsers() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/users/approved');

    DataSnapshot snapshot = await dbRef.get();
    List<UserDetails> users = [];

    if (snapshot.exists) {
      users = (snapshot.value as Map)
          .values
          .map((value) =>
              UserDetails.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    }

    return users;
  }

  Future<bool> addLadduStock(
    DateTime session,
    LadduStock stock,
  ) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a');

    // set return status
    DatabaseReference refRet = dbRef.child('returned');
    try {
      await refRet.set(LadduReturn(
              timestamp: DateTime.now(), to: "", count: -1, user: 'Unknown')
          .toJson());
    } catch (e) {
      return false;
    }

    // Add a new laddu stock
    DateTime timestamp = stock.timestamp;
    DatabaseReference ref = dbRef
        .child('stocks')
        .child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(stock.toJson());
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<bool> editLadduStock(DateTime session, LadduStock stock) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a');

    // Add a new laddu stock
    DateTime timestamp = stock.timestamp;
    DatabaseReference ref = dbRef
        .child('stocks')
        .child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        await ref.set(stock.toJson());
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<void> editLadduReturn(DateTime session, LadduReturn lr) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a/returned');

    // set return status
    DatabaseReference refRet = dbRef.child('count');
    await refRet.set(lr.count);

    refRet = dbRef.child('to');
    await refRet.set(lr.to);
  }

  Future<bool> editLadduServe(DateTime session, LadduServe serve) async {
    String s = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$s');

    // edit laddu stock
    DateTime timestamp = serve.timestamp;
    DatabaseReference ref = dbRef
        .child('serves')
        .child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        await ref.set(serve.toJson());
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<bool> deleteLadduStock(DateTime session, LadduStock stock) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a');

    // delete laddu stock
    DateTime timestamp = stock.timestamp;
    DatabaseReference ref = dbRef
        .child('stocks')
        .child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        await ref.remove();
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  // TODO
  Future<bool> deleteLadduDist(DateTime session, LadduServe dist) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a');

    // delete laddu stock
    DateTime timestamp = dist.timestamp;
    DatabaseReference ref = dbRef
        .child('dists')
        .child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      DataSnapshot snapshot = await ref.get();
      if (snapshot.exists) {
        await ref.remove();
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<List<LadduStock>> readLadduStocks(DateTime session) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a/stocks');

    DataSnapshot snapshot = await dbRef.get();

    List<LadduStock> stocks = [];
    if (snapshot.exists) {
      stocks = (snapshot.value as Map)
          .values
          .map((value) =>
              LadduStock.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    }

    return stocks;
  }

  Future<List<LadduStock>> readLadduStocksByDateRange(
      DateTime startDate, DateTime endDate) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/stocks');

    final Query query = dbRef
        .orderByKey()
        .startAt(startDate.toIso8601String().replaceAll(".", "^"))
        .endAt(endDate.toIso8601String().replaceAll(".", "^"));

    final DataSnapshot snapshot = await query.get();

    if (snapshot.exists) {
      final Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);
      final List<LadduStock> ladduStocks = data.entries
          .map((entry) =>
              LadduStock.fromJson(Map<String, dynamic>.from(entry.value)))
          .toList();
      return ladduStocks;
    } else {
      return [];
    }
  }

  Future<DateTime> addLadduSession() async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva');

    DateTime timestamp = DateTime.now();
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));

    try {
      await ref.set({});
      return timestamp;
    } catch (e) {
      Toaster().error("Database write error: $e");
      return DateTime.now();
    }
  }

  Future<bool> addLadduServe(DateTime session, LadduServe dist) async {
    String s = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$s');

    // Add a new laddu distribution
    DateTime timestamp = dist.timestamp;
    DatabaseReference ref = dbRef
        .child('serves')
        .child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(dist.toJson());
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<List<LadduServe>> readLadduServes(DateTime session) async {
    String s = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$s/serves');

    DataSnapshot snapshot;
    snapshot = await dbRef.get();

    List<LadduServe> serves = [];
    if (snapshot.exists) {
      serves = (snapshot.value as Map)
          .values
          .map((value) =>
              LadduServe.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
    }

    return serves;
  }

  Future<void> returnLadduStock(DateTime session, LadduReturn lr) async {
    String a = session.toIso8601String().replaceAll(".", "^");
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/ladduSeva/$a/returned');

    await dbRef.update({
      'count': lr.count,
      'to': lr.to,
      'timestamp': lr.timestamp.toIso8601String(),
    });
  }
}

class FBCallbacks {
  void Function(String changeType, dynamic data) onChange;

  FBCallbacks({
    required this.onChange,
  });
}
