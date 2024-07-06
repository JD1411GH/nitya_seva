import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nitya_seva/db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SlotTile extends StatefulWidget {
  final String id;
  final String buttonText;
  SlotTileCallbacks? callback;

  bool isInverted = false; // Add the isInverted setter here

  SlotTile({
    super.key,
    required this.id,
    required this.buttonText,
    this.callback,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'buttonText': buttonText,
        // Convert other fields as necessary
      };

  factory SlotTile.fromJson(Map<String, dynamic> json) {
    return SlotTile(
      id: json['id'],
      buttonText: json['buttonText'],
      // Initialize other fields
    );
  }

  @override
  _listSlotTilestate createState() => _listSlotTilestate();
}

class _listSlotTilestate extends State<SlotTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Deselect if slot tile is selected
          if (widget.isInverted) {
            setState(() {
              widget.isInverted = false;
            });
            widget.callback!.onSlotDeselected(widget.id);
          }

          widget.callback!.onSlotClicked(widget.id);
        },
        onLongPress: () {
          setState(() {
            widget.isInverted =
                !widget.isInverted; // Update the reference to widget.isInverted
          });
          widget.callback!.onSlotSelected(widget.id);
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor:
              widget.isInverted // Update the reference to widget.isInverted
                  ? Theme.of(context).colorScheme.primary
                  : null, // Matched to theme's primary color
          foregroundColor:
              widget.isInverted // Update the reference to widget.isInverted
                  ? Theme.of(context).colorScheme.onPrimary
                  : null, // Matched to text color on primary
        ),
        child: Text(widget.buttonText),
      ),
    );
  }
}

class SlotTileList {
  List<SlotTile> listSlotTiles = [];

  final SlotTileCallbacks callback;
  SlotTileList(this.callback);

  Future<void> _save() async {
    String slotsJson =
        jsonEncode(listSlotTiles.map((slot) => slot.toJson()).toList());

    DB().writeCloud('dbSlots', slotsJson);
  }

  void addSlotTile() {
    String text = DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    text = "$text \nJayanta Debnath";

    SlotTile slotTile = SlotTile(
      id: const Uuid().v4(),
      buttonText: text,
      callback: callback,
    );

    listSlotTiles.insert(0, slotTile);
    _save();
  }

  void removeSlotTile(String id) {
    listSlotTiles.removeWhere((element) => element.id == id);
    _save();
  }

  Future<void> initListSlotTiles() async {
    String? slotsJson = await DB().readCloud('dbSlots');

    if (slotsJson != null) {
      List<dynamic> slots = jsonDecode(slotsJson);
      listSlotTiles = slots.map((slot) => SlotTile.fromJson(slot)).toList();

      for (var slotTile in listSlotTiles) {
        slotTile.callback = callback;
      }
    }
  }

  List<SlotTile> getSlotList() {
    return listSlotTiles;
  }

  SlotTile getSlotTileById(String id) {
    return listSlotTiles.firstWhere((slotTile) => slotTile.id == id);
  }

  void clearSelection() {
    for (var slotTile in listSlotTiles) {
      slotTile.isInverted = false;
    }
  }
}

class SlotTileCallbacks {
  final Function(String id) onSlotSelected;
  final Function(String id) onSlotDeselected;
  final Function(String id) onSlotClicked;

  SlotTileCallbacks({
    required this.onSlotSelected,
    required this.onSlotDeselected,
    required this.onSlotClicked,
  });
}
