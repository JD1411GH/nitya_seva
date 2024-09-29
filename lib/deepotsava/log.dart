import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';

class Log extends StatefulWidget {
  final String stall;

  const Log({super.key, required this.stall});

  @override
  State<Log> createState() => _LogState();
}

final GlobalKey<_LogState> LogKey = GlobalKey<_LogState>();

class _LogState extends State<Log> {
  List<DeepamSale> cardValues = [];

  void addLog(DeepamSale sale) {
    setState(() {
      cardValues.add(sale);
    });
  }

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardValues.map((value) {
          return Container(
            width: 100.0, // Fixed width to make it square
            height: 100.0, // Fixed height to make it square
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                "value",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
