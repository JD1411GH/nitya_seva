import 'package:flutter/material.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("Lamps issued: 0"),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("Plates issued: 0"),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text("Total amount: 0"),
          ),
        ],
      ),
    );
  }
}
