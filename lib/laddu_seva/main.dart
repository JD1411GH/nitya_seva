import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/avilability_bar.dart';
import 'package:garuda/laddu_seva/history.dart';
import 'package:garuda/laddu_seva/laddu_calc.dart';
import 'package:garuda/laddu_seva/log.dart';
import 'package:garuda/laddu_seva/summary.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
  initState() {
    super.initState();
    DateTime lastRefresh = DateTime.now();

    FB().listenForChange("ladduSeva",
        FBCallbacks(onChange: (String changeType, dynamic data) async {
      // if the last refresh was more than 2 seconds ago, then refresh the data
      if (DateTime.now().difference(lastRefresh).inSeconds < 2) {
        return;
      }

      await refresh();
    }));
  }

  Future<void> refresh() async {
    if (AvailabilityBarKey.currentState != null) {
      await AvailabilityBarKey.currentState!.refresh();
    }

    if (SummaryKey.currentState != null) {
      await SummaryKey.currentState!.refresh();
    }

    if (LogKey.currentState != null) {
      await LogKey.currentState!.refresh();
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => History()),
              );
            },
            tooltip: 'Complete Log',
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
                    addEditStock(context);
                  },
                  icon: Icon(Icons.add),
                  label: Text('Stock'),
                ),

                // serve button
                ElevatedButton.icon(
                  onPressed: () {
                    addEditDist(context);
                  },
                  icon: Icon(Icons.remove),
                  label: Text('Serve'),
                ),

                // return button
                ElevatedButton.icon(
                  onPressed: () {
                    returnStock(context);
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
