// This database will be replaced by firebase

import 'dart:convert';

import 'package:nitya_seva_calculation/slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBSlotEntry {
  final String id;
  final String text;
  // Add other fields as necessary

  DBSlotEntry({required this.id, required this.text});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        // Convert other fields as necessary
      };
}

class DBSlot {
  static final DBSlot _singleton = DBSlot._internal();
  DBSlot._internal();
  factory DBSlot() {
    return _singleton;
  }
  List<DBSlotEntry> listSlotEntries = [];

  _save() async {
    // Save to database
    String slotsJson =
        jsonEncode(listSlotEntries.map((slot) => slot.toJson()).toList());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dbSlots', slotsJson);
  }

  void addSlot(SlotTile slot) {
    DBSlotEntry entry = DBSlotEntry(id: slot.id, text: slot.buttonText);
    listSlotEntries.insert(0, entry);
    _save();
  }

  void removeSlot(SlotTile slot) =>
      listSlotEntries.removeWhere((element) => element.id == slot.id);

  void showSlots() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? dbSlots = await prefs.getString('dbSlots');
    print(dbSlots);
  }
}
