import 'package:flutter/material.dart';

class SlotTile extends StatefulWidget {
  final String id;
  final String buttonText;
  const SlotTile({super.key, required this.id, required this.buttonText});

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
          // Your button action here
        },
        onLongPress: () {
          setState(() {
            _isInverted = !_isInverted;
          });
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.centerLeft,
          backgroundColor: _isInverted ? Theme.of(context).colorScheme.primary : null, // Matched to theme's primary color
          foregroundColor: _isInverted ? Theme.of(context).colorScheme.onPrimary : null, // Matched to text color on primary
        ),
        child: Text(widget.buttonText),
      ),
    );
  }
}