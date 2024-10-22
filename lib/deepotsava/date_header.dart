import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHeader extends StatefulWidget {
  final DateHeaderCallbacks? callbacks;

  const DateHeader({super.key, this.callbacks});

  @override
  State<DateHeader> createState() => _DateHeaderState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_DateHeaderState> HistoryHeaderKey =
    GlobalKey<_DateHeaderState>();

class _DateHeaderState extends State<DateHeader> {
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

              if (widget.callbacks != null) {
                widget.callbacks!.change(_date);
              }
            },
          ),

          // date
          GestureDetector(
            onTap: () {
              setState(() {
                _date = DateTime.now();
              });

              if (widget.callbacks != null) {
                widget.callbacks!.change(_date);
              }
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
              if (_date.year == DateTime.now().year &&
                  _date.month == DateTime.now().month &&
                  _date.day == DateTime.now().day) {
                return;
              }

              setState(() {
                _date = _date.add(Duration(days: 1));
              });

              if (widget.callbacks != null) {
                widget.callbacks!.change(_date);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DateHeaderCallbacks {
  void Function(DateTime) change;

  DateHeaderCallbacks({
    required this.change,
  });
}
