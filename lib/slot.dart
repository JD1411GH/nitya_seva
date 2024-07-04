import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nitya_seva_calculation/slotdb.dart';
import 'package:uuid/uuid.dart';

class SlotTile extends StatefulWidget {
  final String id;
  final String buttonText;
  final SlotTileCallbacks callback;

  bool isInverted = false; // Add the isInverted setter here

  SlotTile({
    super.key,
    required this.id,
    required this.buttonText,
    required this.callback,
  });

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
          if (widget.isInverted) { // Update the reference to widget.isInverted
            setState(() {
              widget.isInverted = false; // Update the reference to widget.isInverted
            });
            widget.callback.onSlotDeselected(widget.id);
          }
        },
        onLongPress: () {
          setState(() {
            widget.isInverted = !widget.isInverted; // Update the reference to widget.isInverted
          });
          widget.callback.onSlotSelected(widget.id);
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: widget.isInverted // Update the reference to widget.isInverted
              ? Theme.of(context).colorScheme.primary
              : null, // Matched to theme's primary color
          foregroundColor: widget.isInverted // Update the reference to widget.isInverted
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
  DBSlot dbSlot = DBSlot();

  final SlotTileCallbacks callback;
  SlotTileList(this.callback);

  void addSlotTile() {
    String text = DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    text = "$text \nJayanta Debnath";

    SlotTile slotTile = SlotTile(
      id: const Uuid().v4(),
      buttonText: text,
      callback: callback,
    );

    listSlotTiles.insert(0, slotTile);
    dbSlot.addSlot(slotTile);
    dbSlot.showSlots();
  }

  void removeSlotTile(String id) {
    listSlotTiles.removeWhere((element) => element.id == id);
    dbSlot.removeSlot(listSlotTiles.firstWhere((slotTile) => slotTile.id == id));
  }

  List<SlotTile> getSlotList() {
    return listSlotTiles;
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
  // Add more callbacks as needed

  SlotTileCallbacks({
    required this.onSlotSelected,
    required this.onSlotDeselected,
  });
}
