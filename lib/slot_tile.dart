import 'package:flutter/material.dart';

class SlotTile extends StatefulWidget {
  final String id;
  final String buttonText;
  final Function(bool, String)? onSelected;
  const SlotTile({
    super.key,
    required this.id,
    required this.buttonText,
    this.onSelected,
  });

  @override
  _SlotTileState createState() => _SlotTileState();
}

class _SlotTileState extends State<SlotTile> {
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
            if (widget.onSelected != null) {
              widget.onSelected!(false, widget.id);
            }
          }
        },
        onLongPress: () {
          setState(() {
            _isInverted = !_isInverted;
          });
          if (widget.onSelected != null) {
            widget.onSelected!(true, widget.id);
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
