import 'package:shared_preferences/shared_preferences.dart';

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
}
