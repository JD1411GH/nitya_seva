import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/avilability_bar.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/dist_tiles.dart';
import 'package:garuda/laddu_seva/laddu_summary.dart';
import 'package:garuda/laddu_seva/number_selector.dart';
import 'package:garuda/laddu_seva/stock_log.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class LadduDash extends StatefulWidget {
  const LadduDash({super.key});

  @override
  State<LadduDash> createState() => _LadduDashState();
}

final GlobalKey<_LadduDashState> LadduDashKey = GlobalKey<_LadduDashState>();

class _LadduDashState extends State<LadduDash> {
  final _lockInit = Lock();

  Widget _numberSelector = NumberSelector(key: numberSelectorKey);
  Widget _distTiles = DistTiles(key: DistTilesKey);
  Widget _summary = LadduSummary(key: LadduSummaryKey);
  Widget _avlBar = AvailabilityBar(key: AvailabilityBarKey);

  TextEditingController _controllerNote = TextEditingController();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {});
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
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

            // add stock button
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

                  // update stock summary
                  if (LadduSummaryKey.currentState != null) {
                    LadduSummaryKey.currentState!.restock(procured);
                  }

                  // update availability bar
                  if (AvailabilityBarKey.currentState != null) {
                    AvailabilityBarKey.currentState!.refresh();
                  }
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

  void showDialogFailedValidation(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Validation failed',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _getStockButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // restock button
              ElevatedButton(
                onPressed: () {
                  _addStock(context);
                },
                child: Text("Restock"),
              ),

              // logs button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StockLog()),
                  );
                },
                child: Text("Logs"),
              ),

              // validate button
              ElevatedButton(
                onPressed: () async {
                  bool valid = true;

                  // validate stock
                  List<LadduStock> stocks = await FB().readLadduStocks();
                  int sum = 0;
                  stocks.forEach((element) {
                    sum += element.count;
                  });
                  if (sum != LadduSummaryKey.currentState!.total_procured) {
                    valid = false;
                    showDialogFailedValidation(context,
                        "Stock validation failed. \nTotal expected stock = $sum \nTotal actual stock = ${LadduSummaryKey.currentState!.total_procured}");
                    return;
                  }

                  // validate distribution
                  List<LadduDist> dists = await FB().readLadduDists();
                  sum = 0;
                  dists.forEach((element) {
                    sum += element.count;
                  });
                  if (sum != LadduSummaryKey.currentState!.total_distributed) {
                    valid = false;
                    showDialogFailedValidation(context,
                        "Distribution validation failed. \nTotal expected distribution = $sum \nTotal actual distribution = ${LadduSummaryKey.currentState!.total_distributed}");
                    return;
                  }

                  if (valid) {
                    Toaster().info("Validation successful");
                  }
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
                      await LadduSummaryKey.currentState!.refresh();
                      await DistTilesKey.currentState!.refresh();
                      await AvailabilityBarKey.currentState!.refresh();
                      Toaster().info("Add success");
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
              Text(
                DateFormat('EEE, MMM d').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 20.0, // Increase the font size
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
              Divider(),
              _summary,
              _getStockButtons(context),
              Divider(),
              _avlBar,
              _getDistributionWidget(context),
              SizedBox(height: 8.0),
              _distTiles,
            ],
          );
        }
      },
    );
  }
}
