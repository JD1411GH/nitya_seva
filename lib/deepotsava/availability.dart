import 'package:flutter/material.dart';
import 'package:garuda/theme.dart';

class Availability extends StatefulWidget {
  final String stall;

  const Availability({super.key, required this.stall});

  @override
  State<Availability> createState() => _AvailabilityState();
}

GlobalKey<_AvailabilityState> availabilityKey = GlobalKey<_AvailabilityState>();

class _AvailabilityState extends State<Availability> {
  double _currentStock = 0;
  double _fullStock = 0;
  double _barValue = 0;

  @override
  void initState() {
    super.initState();
  }

  void addStock(int stock) {
    setState(() {
      _fullStock += stock;
      _currentStock += stock;

      _barValue = 0.5;
    });
  }

  void removeStock(int stock) {
    setState(() {
      _currentStock -= stock;
    });
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
                value: _barValue,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
          ),
          Text(
            '${_currentStock.toInt()}',
            style: TextStyle(
              color: _barValue > 0.6 ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
