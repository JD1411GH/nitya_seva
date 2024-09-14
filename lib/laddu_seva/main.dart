import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/avilability_bar.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/history.dart';
import 'package:garuda/laddu_seva/laddu_calc.dart';
import 'package:garuda/laddu_seva/log.dart';
import 'package:garuda/laddu_seva/serve.dart';
import 'package:garuda/laddu_seva/summary.dart';
import 'package:intl/intl.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
  DateTime? session;
  LadduReturn? lr;
  DateTime lastRefresh = DateTime.now();

  @override
  initState() {
    super.initState();

    refresh();

    FB().listenForChange("ladduSeva",
        FBCallbacks(onChange: (String changeType, dynamic data) async {
      await refresh();
    }));
  }

  Future<void> refresh() async {
    if (DateTime.now().difference(lastRefresh).inSeconds < 2) {
      return;
    }
    lastRefresh = DateTime.now();

    // refresh the main widget
    session = await FB().readLatestLadduSession();
    lr = await FB().readLadduReturnStatus(session!);
    if (mounted) {
      setState(() {});
    }

    if (AvailabilityBarKey.currentState != null) {
      await AvailabilityBarKey.currentState!.refresh();
    }

    if (SummaryKey.currentState != null) {
      await SummaryKey.currentState!.refresh();
    }

    // refresh Log only when session is open
    if (lr == null || lr!.count == -1) {
      if (LogKey.currentState != null) {
        await LogKey.currentState!.refresh();
      }
    }
  }

  Widget _getReturnTile(LadduReturn lr) {
    return ListTile(
        // title
        title: Text(DateFormat('dd-MM-yyyy HH:mm:ss').format(lr.timestamp),
            style: TextStyle(fontWeight: FontWeight.bold)),

        // icon
        leading: const Icon(Icons.undo),

        // body
        subtitle: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Sevakarta: ${lr.user}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Laddu packs returned: ${lr.count}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Returned to: ${lr.to}'),
            ),
          ],
        ),

        // the count
        trailing: Container(
          padding: EdgeInsets.all(8.0), // Add padding around the text
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0), // Add a border
            borderRadius:
                BorderRadius.circular(12.0), // Make the border circular
          ),
          child: Text(
            lr.count.toString(),
            style: TextStyle(fontSize: 24.0), // Increase the font size
          ),
        ),

        // on tap
        onTap: () async {
          returnStock(context, lr: lr);
        });
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
                  onPressed: (lr == null || lr!.count == -1)
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Serve()),
                          );
                        }
                      : null,
                  icon: Icon(Icons.remove),
                  label: Text('Serve'),
                ),

                // return button
                ElevatedButton.icon(
                  onPressed: (lr == null || lr!.count == -1)
                      ? () {
                          returnStock(context);
                        }
                      : null,
                  icon: Icon(Icons.undo),
                  label: Text('Return'),
                )
              ],
            ),

            Divider(),

            // if session is closed, display a message and the return tile
            if (lr != null && lr!.count >= 0)
              Column(
                children: [
                  Text(
                    "Click '+ Stock' to start new session",
                    style: TextStyle(color: Colors.red, fontSize: 20.0),
                  ),
                  Divider(),
                  _getReturnTile(lr!),
                  Divider(),
                ],
              ),

            Log(key: LogKey),
          ],
        ),
      ),
    );
  }
}
