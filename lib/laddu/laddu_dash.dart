import 'package:flutter/material.dart';
import 'package:garuda/laddu/laddu_tile.dart';
import 'package:garuda/laddu/number_selector.dart';
import 'package:synchronized/synchronized.dart';

class LadduDash extends StatefulWidget {
  const LadduDash({super.key});

  @override
  State<LadduDash> createState() => _LadduDashState();
}

final GlobalKey<_LadduDashState> templateKey = GlobalKey<_LadduDashState>();

class _LadduDashState extends State<LadduDash> {
  final _lockInit = Lock();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {});
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getAvailabilityBar(BuildContext context) {
    int totalStock = 0;
    int currentStock = 0;

    Color progressColor;
    if (currentStock / totalStock < 0.2) {
      progressColor = Colors.redAccent;
    } else if (currentStock / totalStock < 0.5) {
      progressColor = Colors.yellow;
    } else {
      progressColor = Colors.lightGreen;
    }

    // if There is no stock, display a message
    if (currentStock == 0) {
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
              'No stocks available',
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
                  value: currentStock / totalStock,
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

  Widget _getStockAvailability(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total laddu packs procured = "),
          Text("Total laddu packs distributed = "),
          Text("Total laddu packs remaining = "),
          Divider(),
          Text("Laddu packs procured today = "),
          Text("Laddu packs distributed today = "),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: Text("Restock"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: Text("Logs"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: Text("Validate"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getDistributionWidget(BuildContext context) {
    return Column(
      children: [
        NumberSelector(),
        Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () {
                  // Handle give button press
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getDistributionLog(BuildContext context) {
    return DistributionTiles();
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
          return Column(
            children: [
              _getStockAvailability(context),
              Divider(),
              _getAvailabilityBar(context),
              _getDistributionWidget(context),
              _getDistributionLog(context),
            ],
          );
        }
      },
    );
  }
}
