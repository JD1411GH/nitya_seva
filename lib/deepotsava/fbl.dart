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

  Future<void> addStock(String stall, DeepamStock stock) async {
    final DatabaseReference dbRef = FirebaseDatabase.instance
        .ref('record_db${Const().dbVersion}/deepostava/stocks/$stall');

    DateTime timestamp = DateTime.now();
    DatabaseReference ref =
        dbRef.child(timestamp.toIso8601String().replaceAll(".", "^"));
    try {
      await ref.set(stock.toJson());
    } catch (e) {
      Toaster().error("failed to add stock: $e");
    }
  }
}
