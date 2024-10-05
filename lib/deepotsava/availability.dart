import 'package:flutter/material.dart';
import 'package:garuda/theme.dart';

class Availability extends StatefulWidget {
  final String stall;

  const Availability({super.key, required this.stall});

  @override
  State<Availability> createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability> {
  late double _currentStock;
  late double _fullStock;

  @override
  void initState() {
    super.initState();
    _fullStock = 0;
    _currentStock = 0;
  }

  void addStock(int stock) {
    setState(() {
      _fullStock += stock;
      _currentStock += stock;
    });
  }

  void removeStock(int stock) {
    setState(() {
      _currentStock -= stock;
    });
  }

  double _getValue() {
    if (_fullStock == 0) {
      return 0;
    }

    if (_currentStock < 0) {
      return 0;
    }

    if (_currentStock > _fullStock) {
      return 1;
    }

    return _currentStock / _fullStock;
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
                value: _getValue(),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            ),
          ),
          Text(
            '${_currentStock.toInt()}',
            style: TextStyle(
              color: _getValue() > 0.6 ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
