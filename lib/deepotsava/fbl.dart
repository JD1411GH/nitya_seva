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
        callbacks.add(event.snapshot.value);
      }
    });

    dbRef.onChildChanged.listen((event) {
      if (!initialLoad) {
        callbacks.edit();
      }
    });

    // dbRef.onChildRemoved.listen((event) {
    //   if (!initialLoad) {
    //     callbacks.onChange("REMOVE", event.snapshot.value);
    //   }
    // });

    // Set initialLoad to false after the first set of events
    dbRef.once().then((_) {
      initialLoad = false;
    });
  }

  Future<void> addStock(String stall, DeepamStock stock) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/stocks');

    DateTime timestamp = DateTime.now();
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(stock.toJson());
    } catch (e) {
      Toaster().error("failed to add stock: $e");
    }
  }

  Future<void> addSale(String stall, DeepamSale sale) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/sales/');

    DateTime timestamp = DateTime.now();
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(sale.toJson());
    } catch (e) {
      Toaster().error("failed to add sale: $e");
    }
  }

  Future<List<DeepamStock>> getStocks(String stall) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/stocks/');

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final Query query = dbRef
        .orderByKey()
        .startAt(startOfDay.toIso8601String().replaceAll(".", "^"))
        .endAt(endOfDay.toIso8601String().replaceAll(".", "^"));

    List<DeepamStock> stocks = [];
    try {
      DataSnapshot snapshot = await query.get();
      if (snapshot.value == null) {
        return stocks;
      }

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

  Future<List<DeepamSale>> getSales(String stall) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/sales/');

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final Query query = dbRef
        .orderByKey()
        .startAt(startOfDay.toIso8601String().replaceAll(".", "^"))
        .endAt(endOfDay.toIso8601String().replaceAll(".", "^"));

    List<DeepamSale> sales = [];
    try {
      DataSnapshot snapshot = await query.get();
      if (snapshot.value == null) {
        return sales;
      }

      Map<dynamic, dynamic> values = snapshot.value as Map;
      values.forEach((key, value) {
        Map<String, dynamic> v = Map<String, dynamic>.from(value as Map);
        DeepamSale sale = DeepamSale.fromJson(v);
        sales.add(sale);
      });
    } catch (e) {
      Toaster().error("failed to get sales: $e");
    }
    return sales;
  }
}

class FBLCallbacks {
  void Function(dynamic data) add;
  void Function() edit; // full refresh required on edit
  // void Function(dynamic data) delete;

  FBLCallbacks({
    required this.add,
    required this.edit,
  });
}
