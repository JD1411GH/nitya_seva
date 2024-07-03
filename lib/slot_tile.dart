import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class SlotTile extends StatefulWidget {
  final String id;
  final String buttonText;
  final Function()? callback;

  const SlotTile({
    super.key,
    required this.id,
    required this.buttonText,
    this.callback,
  });

  @override
  _listSlotTiletate createState() => _listSlotTiletate();
}

class _listSlotTiletate extends State<SlotTile> {
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
            if (widget.callback != null) {
              widget.callback!();
            }
          }
        },
        onLongPress: () {
          setState(() {
            _isInverted = !_isInverted;
          });
          if (widget.callback != null) {
            widget.callback!();
          }
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
  List<SlotTile> listSlotTile = [];
  final Function() callback;

  SlotTileList(this.callback);

  void addSlotTile() {
    String text = DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    text = "$text \nJayanta Debnath";

    SlotTile slotTile = SlotTile(
      id: const Uuid().v4(),
      buttonText: text,
      callback: callback,
    );

    listSlotTile.insert(0, slotTile);
  }

  void removeSlotTile(String id) {
    listSlotTile.removeWhere((element) => element.id == id);
  }

  List<SlotTile> getSlotList() {
    return listSlotTile;
  }

}

