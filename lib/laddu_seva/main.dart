import 'package:flutter/material.dart';
import 'package:garuda/laddu_seva/avilability_bar.dart';
import 'package:garuda/laddu_seva/button_row.dart';
import 'package:garuda/laddu_seva/log.dart';
import 'package:garuda/laddu_seva/summary.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
  AvailabilityBar _availabilityBar = AvailabilityBar();
  Summary _summary = Summary();
  Log _log = Log();

  Future<void> _refresh() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laddu Seva'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              // Add your onPressed code here!
            },
            tooltip: 'Full Log',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        child: ListView(
          children: [
            _availabilityBar,
            Divider(),
            _summary,
            Divider(),
            ButtonRow(),
            Divider(),
            _log,
          ],
        ),
      ),
    );
  }
}
