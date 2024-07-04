// This database will be replaced by firebase

import 'dart:convert';

import 'package:nitya_seva_calculation/slot.dart';

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
  List<DBSlotEntry> slots = [];

  _save() {
    // Save to database
    String slotsJson = jsonEncode(slots.map((slot) => slot.toJson()).toList());

    print(slotsJson); // This prints the JSON string representation of the list
  }

  void addSlot(SlotTile slot) {
    DBSlotEntry entry = DBSlotEntry(id: slot.id, text: slot.buttonText);
    slots.insert(0, entry);
    _save();
  }

  void removeSlot(SlotTile slot) {
    slots.removeWhere((element) => element.id == slot.id);
  }

  void showSlots() {
    print(slots);
  }
}
