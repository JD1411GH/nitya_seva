import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:synchronized/synchronized.dart';

class AvailabilityBar extends StatefulWidget {
  AvailabilityBar({super.key});

  @override
  State<AvailabilityBar> createState() => _AvailabilityBarState();
}

final GlobalKey<_AvailabilityBarState> AvailabilityBarKey =
    GlobalKey<_AvailabilityBarState>();

class _AvailabilityBarState extends State<AvailabilityBar> {
  final _lockInit = Lock();

  DateTime session = DateTime.now();
  bool returned = false;

  // primitive local variables
  int total_procured = 0;
  int total_served = 0;
  int procured_today = 0;
  int distributed_today = 0;

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      session = await FB().readLatestLadduSession();

      LadduReturn lr = await FB().readLadduReturnStatus(session);
      returned = lr.count >= 0;

      List<LadduStock> stocks = await FB().readLadduStocks(session);
      List<LadduServe> serves = await FB().readLadduServes(session);

      total_procured = 0;
      for (var stock in stocks) {
        total_procured += stock.count;
      }

      total_served = 0;
      for (LadduServe serve in serves) {
        serve.packsPushpanjali.forEach((element) {
          element.forEach((key, value) {
            total_served += value;
          });
        });

        serve.packsOthers.forEach((element) {
          element.forEach((key, value) {
            total_served += value;
          });
        });
      }
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getAvailabilityBar(BuildContext context) {
    int currentStock = total_procured - total_served;

    Color progressColor;
    if (currentStock / total_procured < 0.2) {
      progressColor = Colors.redAccent;
    } else if (currentStock / total_procured < 0.5) {
      progressColor = Colors.amber;
    } else {
      progressColor = Colors.lightGreen;
    }

    // if session is closed, display a message
    if (returned) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(8.0), // Add padding around the text
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red), // Border color
              borderRadius: BorderRadius.circular(12.0), // Rounded edges
            ),
            child: Text(
              'Session Closed',
              style: TextStyle(
                color: Colors.red,
                fontSize: 18.0, // Increase the font size as needed
                fontWeight: FontWeight.bold, // Make the text bold
              ),
            ),
          ),
        ],
      );
    } else {
      // stock is available, show a bar chart
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: LinearProgressIndicator(
                  value:
                      total_procured == 0 ? 0 : currentStock / total_procured,
                  minHeight: 30, // Increased the height to 30
                  color: progressColor,
                ),
              ),
              Text(
                'Available: ${currentStock}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  fontSize: 18.0, // Increase the font size as needed
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _getAvailabilityBarLoading(BuildContext context) {
    // stock is available, show a bar chart
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LinearProgressIndicator(
                value: 100 / 100,
                minHeight: 30, // Increased the height to 30
                color: Colors.grey,
              ),
            ),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0, // Increase the font size as needed
                fontWeight: FontWeight.bold, // Make the text bold
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            // child: CircularProgressIndicator(),
            child: _getAvailabilityBarLoading(context),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return _getAvailabilityBar(context);
        }
      },
    );
  }
}
