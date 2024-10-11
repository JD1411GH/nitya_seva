import 'package:flutter/material.dart';
import 'package:garuda/theme.dart';

class Availability extends StatelessWidget {
  final String stall;
  final double currentStock;
  final double fullStock;

  const Availability(
      {super.key,
      required this.stall,
      required this.currentStock,
      required this.fullStock});

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    ThemeData selectedTheme;
    if (stall == 'RRG') {
      themeColor = primaryColorRRG;
      selectedTheme = themeRRG;
    } else if (stall == 'RKC') {
      themeColor = primaryColorRKC;
      selectedTheme = themeRKC;
    } else {
      themeColor = Colors.transparent;
      selectedTheme = themeDefault;
    }

    double barValue = 0;
    if (fullStock == 0 || currentStock < 0) {
      barValue = 0;
    } else if (currentStock > fullStock) {
      barValue = 1;
    } else {
      barValue = currentStock / fullStock;
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: LinearProgressIndicator(
              value: barValue,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          Text(
            'Available: ${currentStock.toInt()}',
            style: selectedTheme.textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
