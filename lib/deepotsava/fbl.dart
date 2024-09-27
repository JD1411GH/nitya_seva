import 'package:firebase_database/firebase_database.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/toaster.dart';

class FBL {
  static FBL? _instance;
  static Map<String, String> keyCache = {};

  factory FBL() {
    _instance ??= FBL._();
    return _instance!;
  }

  FBL._() {
    // Code to be executed when first instantiated
  }

  Future<void> listenForChange(String path, FBLCallbacks callbacks) async {
    final dbRef =
        FirebaseDatabase.instance.ref('record_db${Const().dbVersion}/$path');

    bool initialLoad = true;

    dbRef.onChildAdded.listen((event) {
      if (!initialLoad) {
        callbacks.onChange("ADD", event.snapshot.value);
      }
    });

    dbRef.onChildChanged.listen((event) {
      if (!initialLoad) {
        callbacks.onChange("UPDATE", event.snapshot.value);
      }
    });

    dbRef.onChildRemoved.listen((event) {
      if (!initialLoad) {
        callbacks.onChange("REMOVE", event.snapshot.value);
      }
    });

    // Set initialLoad to false after the first set of events
    dbRef.once().then((_) {
      initialLoad = false;
    });
  }

  Future<void> addStock(String stall, DeepamStock stock) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/stocks/$stall');

    DateTime timestamp = DateTime.now();
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(stock.toJson());
    } catch (e) {
      Toaster().error("failed to add stock: $e");
    }
  }

  Future<List<DeepamStock>> getStocks(String stall) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/stocks/$stall');

    List<DeepamStock> stocks = [];
    try {
      DataSnapshot snapshot = await dbRef.get();
      Map<dynamic, dynamic> values = snapshot.value as Map;
      values.forEach((key, value) {
        Map<String, dynamic> v = Map<String, dynamic>.from(value as Map);
        DeepamStock stock = DeepamStock.fromJson(v);
        stocks.add(stock);
      });
    } catch (e) {
      Toaster().error("failed to get stocks: $e");
    }
    return stocks;
  }
}

class FBLCallbacks {
  void Function(String changeType, dynamic data) onChange;

  FBLCallbacks({
    required this.onChange,
  });
}
