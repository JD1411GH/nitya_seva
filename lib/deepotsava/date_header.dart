import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class DateHeader extends StatefulWidget {
  const DateHeader({super.key});

  @override
  State<DateHeader> createState() => _DateHeaderState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_DateHeaderState> HistoryHeaderKey =
    GlobalKey<_DateHeaderState>();

class _DateHeaderState extends State<DateHeader> {
  final _lockInit = Lock();
  DateTime _date = DateTime.now();

  @override
  initState() {
    super.initState();

    refresh();
  }

  Future<void> refresh() async {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // previous day button
          IconButton(
            icon: Transform.rotate(
              angle: 3.14, // Rotate 180 degrees to point left
              child: Icon(Icons.play_arrow),
            ),
            onPressed: () {
              setState(() {
                _date = _date.subtract(Duration(days: 1));
              });
            },
          ),

          // date
          GestureDetector(
            onTap: () {
              setState(() {
                _date = DateTime.now();
              });
            },
            child: Container(
              width: 120.0,
              alignment: Alignment.center,
              child: Text(
                DateFormat('EEE, dd MMM').format(_date),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ), // Adjust the font size as needed
              ),
            ),
          ),

          // next day button
          IconButton(
            icon: Icon(Icons.play_arrow), // Default points right
            onPressed: () {
              setState(() {
                _date = _date.add(Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }
}
