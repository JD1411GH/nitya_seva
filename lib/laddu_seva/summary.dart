import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/utils.dart';
import 'package:garuda/utils.dart';
import 'package:synchronized/synchronized.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_SummaryState> SummaryKey = GlobalKey<_SummaryState>();

class _SummaryState extends State<Summary> {
  final _lockInit = Lock();

  int total_procured = 0;
  int total_served = 0;

  LadduReturn? lr;

  List<String> barLabels = [];
  List<int> barValues = [];
  List<PieChartSectionData> pieSections = [];
  List<Widget> pieLegends = [];

  String sessionTitle = '';

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      DateTime session = await FB().readLatestLadduSession();
      List<LadduStock> stocks = await FB().readLadduStocks(session);
      List<LadduServe> serves = await FB().readLadduServes(session);

      // set laddu return status
      FB().readLadduReturnStatus(session).then((value) {
        lr = value;
      });

      // formulate session title for summary widget
      sessionTitle = await CalculateSessionTitle(session);

      total_procured = 0;
      for (var stock in stocks) {
        total_procured += stock.count;
      }

      pieSections = [];
      pieLegends = [];
      List<String> labels = [];
      List<int> values = [];

      total_served = 0;
      for (var serve in serves) {
        total_served += CalculateTotalLadduPacksServed(serve);

        // calculate pie chart values for Pushpanjali Seva
        serve.packsPushpanjali.forEach((element) {
          String purpose = "Seva ${element.keys.first}";
          int count = element.values.first;
          if (count > 0) {
            if (labels.contains(purpose)) {
              int index = labels.indexOf(purpose);
              values[index] += count;
            } else {
              labels.add(purpose);
              values.add(count);
            }
          }
        });

        // calculate pie chart values for other Seva
        serve.packsOtherSeva.forEach((element) {
          String purpose = "${element.keys.first}";
          int count = element.values.first;
          if (count > 0) {
            if (labels.contains(purpose)) {
              int index = labels.indexOf(purpose);
              values[index] += count;
            } else {
              labels.add(purpose);
              values.add(count);
            }
          }
        });

        // calculate pie chart values for misc
        serve.packsMisc.forEach((element) {
          String purpose = element.keys.first;
          int count = element.values.first;
          if (count > 0) {
            if (labels.contains(purpose)) {
              int index = labels.indexOf(purpose);
              values[index] += count;
            } else {
              labels.add(purpose);
              values.add(count);
            }
          }
        });
      }

      // populate bar chart data
      barLabels = labels;
      barValues = values;
      _sortBarLabelsAndValues(barLabels, barValues);

      // move the seva elements first
      pieLegends.sort((a, b) {
        String textA = ((a as Row).children[2] as Text).data ?? '';
        String textB = ((b as Row).children[2] as Text).data ?? '';
        return textB.compareTo(textA);
      });

      // sort again based on seva amount
      pieLegends.sort((a, b) {
        String textA = ((a as Row).children[2] as Text).data ?? '';
        String textB = ((b as Row).children[2] as Text).data ?? '';
        if (textA.startsWith("Seva") && textB.startsWith("Seva")) {
          int amountA = int.parse(textA.split(' ')[1]);
          int amountB = int.parse(textB.split(' ')[1]);
          return amountA.compareTo(amountB);
        } else {
          return 0;
        }
      });
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  void _sortBarLabelsAndValues(List<String> labels, List<int> values) {
    // Step 1: Combine labels and values into a list of tuples
    List<MapEntry<String, int>> combinedList = [];
    for (int i = 0; i < labels.length; i++) {
      combinedList.add(MapEntry(labels[i], values[i]));
    }

    // Step 2: Define the custom comparator function
    int customComparator(MapEntry<String, int> a, MapEntry<String, int> b) {
      bool aIsSeva = a.key.startsWith('Seva');
      bool bIsSeva = b.key.startsWith('Seva');

      if (aIsSeva && bIsSeva) {
        // Extract numeric part after 'Seva' and compare numerically
        int aNum = int.parse(a.key.substring(4));
        int bNum = int.parse(b.key.substring(4));
        return aNum.compareTo(bNum);
      } else if (aIsSeva) {
        return -1; // 'Seva' labels come before others
      } else if (bIsSeva) {
        return 1; // 'Seva' labels come before others
      } else {
        return a.key.compareTo(b.key); // Standard string comparison
      }
    }

    // Step 3: Sort the combined list using the custom comparator
    combinedList.sort(customComparator);

    // Step 4: Separate the sorted tuples back into barLabels and barValues
    for (int i = 0; i < combinedList.length; i++) {
      labels[i] = combinedList[i].key;
      values[i] = combinedList[i].value;
    }
  }

  void restock(int procured) {
    total_procured += procured;
    setState(() {});
  }

  Widget _getBarChart(BuildContext context) {
    const double barChartHeight = 150.0; // Set a fixed height for the bar chart

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            height: barChartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(barLabels.length, (index) {
                Color barColor;
                switch (barLabels[index]) {
                  case "Seva 400":
                    barColor = Const().ticketColors['400']!;
                    break;
                  case "Seva 500":
                    barColor = Const().ticketColors['500']!;
                    break;
                  case "Seva 1000":
                    barColor = Const().ticketColors['1000']!;
                    break;
                  case "Seva 2500":
                    barColor = Const().ticketColors['2500']!;
                    break;
                  default:
                    barColor = Utils().getRandomDarkColor();
                }

                // Add newline character to the labels
                String label = barLabels[index].replaceAll(' ', '\n') + ' ';

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(barValues[index].toString()),
                      SizedBox(height: 4),
                      Flexible(
                        child: Container(
                          height: (barValues[index] /
                                  barValues.reduce((a, b) => a > b ? a : b)) *
                              (barChartHeight -
                                  50), // Adjust bar height proportionally
                          color: barColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(label, textAlign: TextAlign.center),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBarChartEmpty(BuildContext context) {
    const double barChartHeight = 150.0; // Set a fixed height for the bar chart
    const int numberOfBars = 5; // Define the number of bars for the placeholder
    const List<String> barLabels = [
      'loading values',
      'loading values',
      'loading values',
      'loading values',
      'loading values'
    ]; // Placeholder labels
    const List<int> barValues = [
      50,
      40,
      30,
      20,
      10
    ]; // Values in descending order
    const Color barColor = Colors.grey; // Set bar color to grey
    const Color textColorDefault = Colors.grey; // Set text color to grey

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Container(
            height: barChartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(numberOfBars, (index) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        barValues[index].toString(),
                        style: TextStyle(
                            color: textColorDefault), // Set text color
                      ),
                      SizedBox(height: 4),
                      Flexible(
                        child: Container(
                          height:
                              barValues[index].toDouble(), // Height for bars
                          color: barColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        barLabels[index],
                        style: TextStyle(
                            color: textColorDefault), // Set text color
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLoading(BuildContext context) {
    return Column(
      children: [
        _getSessionTitle(),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Total laddu packs procured = ..."),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Total laddu packs served = ..."),
          ),
        ),

        // padding before pie chart
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _getBarChartEmpty(context),
        ),
      ],
    );
  }

  Widget _getSessionTitle() {
    return Align(
      alignment: Alignment.center,
      child: Text(
        sessionTitle,
        style: TextStyle(
          fontSize: 16.0, // Increase the font size
          fontWeight: FontWeight.bold, // Make the text bold
        ),
      ),
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
            child: _getLoading(context),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Column(
            children: [
              _getSessionTitle(),

              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Total laddu packs procured = $total_procured"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Total laddu packs served = $total_served"),
                ),
              ),

              // write return count if session closed
              if (lr != null && lr!.count >= 0) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Total laddu packs returned = ${lr!.count}"),
                  ),
                ),

                // calculate missing if any
                if (total_procured != total_served + lr!.count) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Total laddu packs missing = ${total_procured - total_served - lr!.count}",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ],

              // padding before pie chart
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _getBarChart(context),
              ),
            ],
          );
        }
      },
    );
  }
}
