import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/avilability_bar.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/history.dart';
import 'package:garuda/laddu_seva/laddu_calc.dart';
import 'package:garuda/laddu_seva/log.dart';
import 'package:garuda/laddu_seva/service_select.dart';
import 'package:garuda/laddu_seva/summary.dart';
import 'package:garuda/laddu_seva/utils.dart';
import 'package:garuda/toaster.dart';
import 'package:intl/intl.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
  DateTime? session;
  LadduReturn? lr;

  @override
  initState() {
    super.initState();

    refresh().then((data) async {
      await _ensureReturn(context);

      FB().listenForChange("ladduSeva",
          FBCallbacks(onChange: (String changeType, dynamic data) async {
        await refresh();
      }));
    });
  }

  Future<void> refresh() async {
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

  Widget _createReturnTile(LadduReturn lr) {
    return ListTile(
        // title
        title: Text(
          DateFormat('dd-MM-yyyy HH:mm:ss').format(lr.timestamp),
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8A0303)),
        ),

        // icon
        leading: Icon(Icons.undo, color: Color(0xFF8A0303)),

        // body
        subtitle: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sevakarta: ${lr.user}',
                style: TextStyle(color: Color(0xFF8A0303)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Laddu packs returned: ${lr.count}',
                style: TextStyle(color: Color(0xFF8A0303)),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Returned to: ${lr.to}',
                style: TextStyle(color: Color(0xFF8A0303)),
              ),
            ),
          ],
        ),

        // the count
        trailing: Container(
          padding: EdgeInsets.all(8.0), // Add padding around the text
          decoration: BoxDecoration(
            color: Colors.red[50], // Change background color to red
            border: Border.all(
                color: Color(0xFF8A0303), width: 2.0), // Add a border
            borderRadius:
                BorderRadius.circular(12.0), // Make the border circular
          ),
          child: Text(
            lr.count.toString(),
            style: TextStyle(
                fontSize: 24.0,
                color: Color(0xFF8A0303)), // Increase the font size
          ),
        ),

        // on tap
        onTap: () async {
          returnStock(context, lr: lr);
        });
  }

  Future<void> _ensureReturn(BuildContext context) async {
    if (lr == null || lr!.count == -1) {
      // session in progress

      DateTime session = await FB().readLatestLadduSession();
      List<LadduServe> serves = await FB().readLadduServes(session);

      // check if last serve is more than 2 days old
      if (serves.isNotEmpty &&
          serves.last.timestamp
              .isBefore(DateTime.now().subtract(Duration(days: 2)))) {
        // totatl stock
        List<LadduStock> stocks = await FB().readLadduStocks(session);
        stocks.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        if (stocks.isEmpty) {
          return;
        }
        int totalStock = stocks.fold(
            0, (previousValue, element) => previousValue + element.count);

        // total serve
        int totalServe = 0;
        serves.forEach((serve) {
          totalServe += CalculateTotalLadduPacksServed(serve);
        });

        int remaining = totalStock - totalServe;
        if (remaining < 0) {
          remaining = 0;
        }

        await FB().returnLadduStock(
            session,
            LadduReturn(
                timestamp: DateTime.now(),
                count: remaining,
                to: "Unknown",
                user: "Auto Return"));

        Toaster().info("Auto returned");
      }
    }
  }

  void _createServeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiceSelect();
      },
    );
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
                      ? () async {
                          _createServeDialog(context);
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
                  _createReturnTile(lr!),
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
