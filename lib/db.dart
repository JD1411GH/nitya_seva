import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class DB {
  static final DB _instance = DB._internal();

  factory DB() {
    return _instance;
  }

  DB._internal();

  Future<String?> read(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> write(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<void> delete(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  Future<String?> readCloud(String key) async {
    final databaseReference = FirebaseDatabase.instance.ref();

    try {
      DataSnapshot snapshot = await databaseReference.child(key).get();
      return snapshot.value.toString();
    } catch (e) {
      return null;
    }
  }

  Future<bool> writeCloud(String key, String value) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    try {
      await databaseReference.child(key).set(value);
      return true; // Write was successful
    } catch (e) {
      return false; // Write failed
    }
  }

  Future<bool> deleteCloud(String key) async {
    final databaseReference = FirebaseDatabase.instance.ref();
    try {
      await databaseReference.child(key).remove();
      return true; // Delete was successful
    } catch (e) {
      return false; // Delete failed
    }
  }
}
