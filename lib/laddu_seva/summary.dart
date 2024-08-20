import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
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

  List<PieChartSectionData> pieSections = [];

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      total_procured = await FB().readLadduStockTotal();
      total_distributed = await FB().readLadduDistSum();

      // data for pie chart
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 30));

      List<LadduStock> stocks =
          await FB().readLadduStocksByDateRange(startDate, endDate);
      stocks.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      List<LadduDist> dists =
          await FB().readLadduDistsByDateRange(startDate, endDate);
      dists.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // add the sections
      // Const().ticketAmounts.forEach((value) {
      //   pieSections.add(PieChartSectionData(
      //     color: Const().ticketColors['$value']!,
      //     value: value,
      //     title: '',
      //     radius: 50,
      //     titleStyle: TextStyle(
      //         fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      //   ));
      // });
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
          children: [
            _buildLegendItem(Colors.blue, 'Blue - 40%'),
            _buildLegendItem(Colors.red, 'Red - 30%'),
            _buildLegendItem(Colors.green, 'Green - 20%'),
            _buildLegendItem(Colors.yellow, 'Yellow - 10%'),
          ],
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
            child: Text("Total laddu packs distributed = ..."),
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
                  child: Text(
                      "Total laddu packs distributed = $total_distributed"),
                ),
              ),

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
