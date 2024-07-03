import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SlotTile extends StatefulWidget {
  final String id;
  final String buttonText;
  final SlotTileCallbacks callback;

  const SlotTile({
    super.key,
    required this.id,
    required this.buttonText,
    required this.callback,
  });

  @override
  _listSlotTilestate createState() => _listSlotTilestate();
}

class _listSlotTilestate extends State<SlotTile> {
  bool _isInverted = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_isInverted) {
            setState(() {
              _isInverted = false;
            });
            widget.callback.onSlotDeselected(widget.id);
          }
        },
        onLongPress: () {
          setState(() {
            _isInverted = !_isInverted;
          });
          widget.callback.onSlotSelected(widget.id);
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: _isInverted
              ? Theme.of(context).colorScheme.primary
              : null, // Matched to theme's primary color
          foregroundColor: _isInverted
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

  void addSlotTile() {
    String text = DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    text = "$text \nJayanta Debnath";

    SlotTile slotTile = SlotTile(
      id: const Uuid().v4(),
      buttonText: text,
      callback: callback,
    );

    listSlotTiles.insert(0, slotTile);
  }

  void removeSlotTile(String id) {
    listSlotTiles.removeWhere((element) => element.id == id);
  }

  List<SlotTile> getSlotList() {
    return listSlotTiles;
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
