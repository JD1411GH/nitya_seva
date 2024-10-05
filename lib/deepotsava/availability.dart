import 'package:flutter/material.dart';
import 'package:garuda/theme.dart';

class Availability extends StatefulWidget {
  final String stall;
  final double currentStock;
  final double fullStock;

  const Availability(
      {super.key,
      required this.stall,
      required this.currentStock,
      required this.fullStock});

  @override
  State<Availability> createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    if (widget.stall == 'RRG') {
      themeColor = primaryColorRRG;
    } else if (widget.stall == 'RKC') {
      themeColor = primaryColorRKC;
    } else {
      themeColor = Colors.transparent;
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: RotatedBox(
              quarterTurns: -1,
              child: LinearProgressIndicator(
                value: widget.currentStock / widget.fullStock,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
          ),
          Text(
            '${widget.currentStock.toInt()}',
            style: TextStyle(
              color: (widget.currentStock / widget.fullStock) > 0.6
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
