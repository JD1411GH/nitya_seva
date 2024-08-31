import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/toaster.dart';
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
  int total_distributed = 0;

  LadduReturn? lr;

  List<PieChartSectionData> pieSections = [];
  List<Widget> pieLegends = [];

  String sessionTitle = '';

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      DateTime session = await FB().readLatestLadduSession();
      List<LadduStock> stocks = await FB().readLadduStocks(session);
      List<LadduDist> dists = await FB().readLadduDists(session);

      sessionTitle = "${session.day}/${session.month}/${session.year}";
      lr = await FB().readLadduReturnStatus(session);
      if (lr!.count > 0) {
        String endSession =
            "${lr!.timestamp.day}/${lr!.timestamp.month}/${lr!.timestamp.year}";
        if (sessionTitle != endSession) {
          sessionTitle += " - $endSession";
        }
      }

      total_procured = 0;
      for (var stock in stocks) {
        total_procured += stock.count;
      }

      total_distributed = 0;
      for (var dist in dists) {
        total_distributed += dist.count;
      }

      pieSections = [];
      pieLegends = [];

      List<String> labels = [];
      List<int> values = [];

      dists.forEach((dist) {
        if (labels.contains(dist.purpose)) {
          int index = labels.indexOf(dist.purpose);
          values[index] += dist.count;
        } else {
          labels.add(dist.purpose);
          values.add(dist.count);
        }
      });

      // add the pie sections and legends
      for (int i = 0; i < labels.length; i++) {
        Color pieColor = Colors.grey;
        Color textColor = Colors.white;
        if (labels[i].startsWith("Seva")) {
          String amount = labels[i].split(' ')[1];
          pieColor = Const().ticketColors[amount]!;
          textColor =
              amount == "500" ? Theme.of(context).primaryColor : Colors.white;
        } else {
          if (labels[i] == "Others") {
            pieColor = Colors.grey;
          } else if (labels[i] == "Missing") {
            pieColor = Colors.redAccent;
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

  Widget _getPieChart(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 100, // Set the desired height
          width: 100, // Set the desired width
          child: PieChart(
            PieChartData(
              sections: pieSections,
            ),
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
            _buildLegendItem(Colors.grey, 'Loading...'),
          ],
        ),
      ],
    );
  }

  Widget _getLoading(BuildContext context) {
    return Column(
      children: [
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
                  child: Text("Total laddu packs served = $total_distributed"),
                ),
              ),

              // write return count if session closed
              if (lr != null && lr!.count > 0) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Total laddu packs returned = ${lr!.count}"),
                  ),
                ),
              ],

              // padding before pie chart
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _getPieChart(context),
              ),
            ],
          );
        }
      },
    );
  }
}
