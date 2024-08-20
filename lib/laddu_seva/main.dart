import 'package:flutter/material.dart';
import 'package:garuda/laddu_seva/avilability_bar.dart';
import 'package:garuda/laddu_seva/laddu_calc.dart';
import 'package:garuda/laddu_seva/log.dart';
import 'package:garuda/laddu_seva/summary.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
  Future<void> refresh() async {
    if (AvailabilityBarKey.currentState != null) {
      AvailabilityBarKey.currentState!.refresh();
    }

    if (SummaryKey.currentState != null) {
      SummaryKey.currentState!.refresh();
    }

    if (LogKey.currentState != null) {
      LogKey.currentState!.refresh();
    }
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
        onRefresh: refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        child: ListView(
          children: [
            AvailabilityBar(key: AvailabilityBarKey),

            Divider(),
            Summary(key: SummaryKey),

            // button row
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // stock button
                ElevatedButton.icon(
                  onPressed: () async {
                    addStock(context, refresh);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Stock'),
                ),

                // serve button
                ElevatedButton.icon(
                  onPressed: () {
                    removeStock(context, refresh);
                  },
                  icon: Icon(Icons.remove),
                  label: Text('Serve'),
                ),

                // return button
                ElevatedButton.icon(
                  onPressed: () {
                    returnStock(context, refresh);
                  },
                  icon: Icon(Icons.undo),
                  label: Text('Return'),
                ),
              ],
            ),

            Divider(),
            Log(key: LogKey),
          ],
        ),
      ),
    );
  }
}
