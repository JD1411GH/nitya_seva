import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/dist_tiles.dart';
import 'package:garuda/laddu_seva/number_selector.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:synchronized/synchronized.dart';

class LadduDash extends StatefulWidget {
  const LadduDash({super.key});

  @override
  State<LadduDash> createState() => _LadduDashState();
}

class _LadduDashState extends State<LadduDash> {
  final _lockInit = Lock();
  TextEditingController _controllerNote = TextEditingController();

  Widget _numberSelector = NumberSelector(key: numberSelectorKey);

  int total_procured = 0;
  int total_distributed = 0;
  int procured_today = 0;
  int distributed_today = 0;

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      total_procured = await FB().readLadduStockTotal();
      total_distributed = await FB().readLadduDistSum();
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

  void _addStock(BuildContext context) {
    int procured = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Packs procured'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  procured = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            // cancel button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),

            // add button
            ElevatedButton(
              onPressed: () async {
                var u = await LS().read('user_details');
                if (u != null) {
                  var uu = jsonDecode(u);
                  UserDetails user = UserDetails.fromJson(uu);

                  LadduStock stock = LadduStock(
                    timestamp: DateTime.now(),
                    user: user.name!,
                    count: procured,
                  );

                  bool status = await FB().addLadduStock(stock);
                  if (!status) {
                    Toaster().error("Add failed");
                  }

                  setState(() {
                    total_procured += procured;
                  });
                } else {
                  Toaster().error("Error");
                }
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _getAvailabilityWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Total laddu packs procured = $total_procured"),
          Text("Total laddu packs distributed = $total_distributed"),
          Text(
              "Total laddu packs remaining = ${total_procured - total_distributed}"),
          Divider(),
          Text("Laddu packs procured today = "),
          Text("Laddu packs distributed today = "),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _addStock(context);
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
        // number selector
        _numberSelector,

        // note and send buttons
        Container(
          alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextField(
                    controller: _controllerNote,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  int countLaddu =
                      numberSelectorKey.currentState!.selectedNumber;

                  if (countLaddu > 0) {
                    String username = await Const().getUserName();

                    LadduDist dist = LadduDist(
                      timestamp: DateTime.now(),
                      user: username,
                      count: countLaddu,
                      note: _controllerNote.text,
                    );

                    bool status = await FB().addLadduDist(dist);
                    if (status) {
                      await _futureInit();
                      setState(() {
                        Toaster().info("Add success");
                      });
                    } else {
                      Toaster().error("Add failed");
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getDistributionTiles(BuildContext context) {
    return DistTiles();
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
              _getAvailabilityWidget(context),
              Divider(),
              _getAvailabilityBar(context),
              _getDistributionWidget(context),
              SizedBox(height: 8.0),
              _getDistributionTiles(context),
            ],
          );
        }
      },
    );
  }
}
