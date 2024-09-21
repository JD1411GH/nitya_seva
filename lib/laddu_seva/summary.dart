import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/utils.dart';
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

  List<BarChartGroupData> barChartData = [];
  List<String> labels = [];
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
      labels = [];
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

      print("labels: $labels");
      print("values: $values");
      barChartData = [];
      for (int i = 0; i < values.length; i++) {
        barChartData.add(BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: values[i].toDouble(),
              color: Colors.blue,
            ),
          ],
          showingTooltipIndicators: [0], // Optional: to show tooltips
        ));
      }

      List<String> sevaNames = Const().otherSevaTickets.map((e) {
        String name = e['name'];
        return name;
      }).toList();

      // add the pie sections and legends
      for (int i = 0; i < labels.length; i++) {
        Color pieColor = Colors.grey;
        Color textColor = Colors.white;
        if (labels[i].startsWith("Seva")) {
          String amount = labels[i].split(' ')[1];
          pieColor = Const().ticketColors[amount]!;
          textColor =
              amount == "500" ? Theme.of(context).primaryColor : Colors.white;
        } else if (sevaNames.contains(labels[i])) {
          int index = sevaNames.indexOf(labels[i]);
          pieColor = Const().otherSevaTickets[index]['color'];
        } else {
          if (labels[i] == "Miscellaneous") {
            pieColor = Colors.grey;
          } else {
            pieColor = Const().getRandomDarkColor();
          }
        }

        double value = values[i].toDouble();
        double percentage = (value / values.reduce((a, b) => a + b)) * 100;
        double titlePositionPercentageOffset = percentage < 10 ? 1.2 : 0.5;
        if (percentage < 10) {
          textColor = Theme.of(context).primaryColor;
        }

        pieSections.add(PieChartSectionData(
          color: pieColor,
          value: value,
          title: values[i].toString(),
          radius: 50,
          titleStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
          titlePositionPercentageOffset: titlePositionPercentageOffset,
        ));

        pieLegends.add(_buildLegendItem(pieColor, labels[i]));
      }

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

  void restock(int procured) {
    total_procured += procured;
    setState(() {});
  }

  Widget _getBarChart(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Set the desired width
      height: 150, // Set the desired height
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Transform.rotate(
                      angle: -45 *
                          3.1415926535897932 /
                          180, // Rotate by -45 degrees
                      child: Text(labels[index]),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: true),
          barGroups: barChartData,
        ),
      ),
    );
  }

  Widget _getPieChart(BuildContext context) {
    if (pieSections.isEmpty) {
      return _getPieChartEmpty(context);
    }

    // Shuffle the pie sections to avoid adjacent placement
    pieSections.shuffle(Random());

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: Column(
            children: [
              SizedBox(
                height: 100, // Set the desired height for the PieChart
                width: 100, // Set the desired width for the PieChart
                child: PieChart(
                  PieChartData(
                    sections: pieSections,
                  ),
                ),
              ),

              SizedBox(
                  height: 16), // Increased space between the chart and the text

              Text(
                'Laddu packs served', // Replace with your desired text
              ),
            ],
          ),
        ),
        SizedBox(width: 40), // Increased space between the chart and the legend
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pieLegends,
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  Widget _getPieChartEmpty(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100, // Set the desired height
          width: 100, // Set the desired width
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.grey,
                  value: 100,
                  title: '',
                  radius: 50,
                  titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 40), // Increased space between the chart and the legend
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(Colors.grey, 'No data'),
          ],
        ),
      ],
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
          child: _getPieChartEmpty(context),
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
