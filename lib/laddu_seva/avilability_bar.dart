import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:synchronized/synchronized.dart';

class AvailabilityBar extends StatefulWidget {
  const AvailabilityBar({super.key});

  @override
  State<AvailabilityBar> createState() => _AvailabilityBarState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_AvailabilityBarState> AvailabilityBarKey =
    GlobalKey<_AvailabilityBarState>();

class _AvailabilityBarState extends State<AvailabilityBar> {
  final _lockInit = Lock();

  // primitive local variables
  int total_procured = 0;
  int total_distributed = 0;
  int procured_today = 0;
  int distributed_today = 0;

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      total_procured = await FB().readLadduStockTotal();
      total_distributed = await FB().readLadduDistSum();

      // get today's stock
      List<LadduStock> stocks =
          await FB().readLadduStocks(date: DateTime.now());
      procured_today = 0;
      for (var stock in stocks) {
        procured_today += stock.count;
      }

      // get today's distribution
      List<LadduDist> dists = await FB().readLadduDists(date: DateTime.now());
      distributed_today = 0;
      for (var dist in dists) {
        distributed_today += dist.count;
      }
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getAvailabilityBar(BuildContext context) {
    int currentStock = total_procured - total_distributed;

    Color progressColor;
    if (currentStock / total_procured < 0.2) {
      progressColor = Colors.redAccent;
    } else if (currentStock / total_procured < 0.5) {
      progressColor = Colors.amber;
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
                  value: currentStock / total_procured,
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
          return _getAvailabilityBar(context);
        }
      },
    );
  }
}