import 'package:firebase_database/firebase_database.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
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

    // Check if the path exists
    try {
      await dbRef.get();
    } catch (e) {
      Toaster().error("Database path doesn't exist or no access");
      return;
    }

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

    dbRef.onChildRemoved.listen((event) {
      if (!initialLoad) {
        callbacks.delete(event.snapshot.value);
      }
    });

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

    DateTime timestamp = sale.timestamp;
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(sale.toJson());
    } catch (e) {
      Toaster().error("failed to add sale: $e");
    }
  }

  Future<void> editSale(String stall, DeepamSale sale) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/sales/');

    DateTime timestamp = sale.timestamp;
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(sale.toJson());
    } catch (e) {
      Toaster().error("failed to edit sale: $e");
    }
  }

  Future<void> deleteSale(String stall, DeepamSale sale) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/sales/');

    DateTime timestamp = sale.timestamp;
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.remove();
    } catch (e) {
      Toaster().error("failed to delete sale: $e");
    }
  }

  Future<void> discardLamps(String stall, DeepamSale sale) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/discards/');

    DateTime timestamp = sale.timestamp;
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(sale.toJson());
    } catch (e) {
      Toaster().error("Error writing database: $e");
    }
  }

  Future<List<DeepamStock>> getStocks(String stall) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/stocks/');

    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final Query query = dbRef
        .orderByKey()
        .startAt(start.toIso8601String().replaceAll(".", "^"))
        .endAt(end.toIso8601String().replaceAll(".", "^"));

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

  Future<List<DeepamSale>> getSales(String stall,
      {DateTime? start, DateTime? end}) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepotsava/$stall/sales/');

    DateTime now = DateTime.now();
    if (start == null) {
      start = DateTime(now.year, now.month, now.day);
    }
    if (end == null) {
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    }

    final Query query = dbRef
        .orderByKey()
        .startAt(start.toIso8601String().replaceAll(".", "^"))
        .endAt(end.toIso8601String().replaceAll(".", "^"));

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
  void Function(dynamic data) delete;

  FBLCallbacks({
    required this.add,
    required this.edit,
    required this.delete,
  });
}
