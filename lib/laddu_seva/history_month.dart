import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class HistoryMonth extends StatefulWidget {
  const HistoryMonth({super.key});

  @override
  State<HistoryMonth> createState() => _HistoryMonthState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_HistoryMonthState> templateKey =
    GlobalKey<_HistoryMonthState>();

class _HistoryMonthState extends State<HistoryMonth> {
  final _lockInit = Lock();
  String currentMonth = "";

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      currentMonth = DateFormat('MMMM-yyyy').format(DateTime.now());
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Transform.rotate(
                    angle: 3.14, // Rotate 180 degrees to point left
                    child: Icon(Icons.play_arrow),
                  ),
                  onPressed: () {
                    // Handle previous button click
                  },
                ),
                GestureDetector(
                  onTap: () {
                    // Handle text click
                  },
                  child: Text(
                    currentMonth,
                    style: TextStyle(
                        fontSize: 24.0), // Adjust the font size as needed
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.play_arrow), // Default points right
                  onPressed: () {
                    // Handle next button click
                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
