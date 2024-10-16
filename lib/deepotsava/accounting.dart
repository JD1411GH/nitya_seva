import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/theme.dart';

class Accounting extends StatefulWidget {
  @override
  _AccountingState createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {
  Map<String, int> countMode = {
    // {mode: count}
    'UPI': 30,
    'Cash': 30,
    'Card': 20,
    'Gift': 20,
  };

  Map<String, int> countModePercentage = {
    // {mode: percentage}
    'UPI': 30,
    'Cash': 30,
    'Card': 20,
    'Gift': 20,
  };

  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  PieChartSectionData _createPieSection(mode) {
    Color color = Colors.grey;
    color = Const().paymentModes[mode]?['color'] as Color;

    return PieChartSectionData(
      color: color,
      value: countModePercentage[mode]!.toDouble(),
      title: countMode[mode].toString(),
      radius: 40,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: countModePercentage[mode]! > 9
            ? Colors.white
            : Theme.of(context).textTheme.bodyLarge!.color,
      ),
      titlePositionPercentageOffset: countModePercentage[mode]! > 9 ? 0.5 : 1.2,
    );
  }

  Widget _createPieChart(BuildContext context) {
    if (countModePercentage['UPI'] == 0 &&
        countModePercentage['Cash'] == 0 &&
        countModePercentage['Card'] == 0 &&
        countModePercentage['Gift'] == 0) {
      return const Text("");
    }

    return PieChart(
      PieChartData(
        sections: [
          // UPI
          _createPieSection('UPI'),

          // cash
          _createPieSection('Cash'),

          // card
          _createPieSection('Card'),

          // gift
          _createPieSection('Gift'),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 8,
      ),
    );
  }

  Widget _createPieLegends() {
    List<Widget> children = [];

    Const().paymentModes.forEach((mode, details) {
      if (countModePercentage[mode] != 0) {
        children.add(_createLegendItem(details['color'] as Color, mode));
      }
    });

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Widget _createLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _createDashboard() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: DataTable(
          columns: [
            DataColumn(label: Text('')),
            DataColumn(label: Text('RKC')),
            DataColumn(label: Text('RRG')),
            DataColumn(label: Text('Sum')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('Prepared lamps')),
              DataCell(Text('100')), // Add your data here
              DataCell(Text('150')), // Add your data here
              DataCell(Text('')), // Add your data here
            ]),
            DataRow(cells: [
              DataCell(Text('Unprepared lamps')),
              DataCell(Text('20')), // Add your data here
              DataCell(Text('50')), // Add your data here
              DataCell(Text('')), // Add your data here
            ]),
            DataRow(cells: [
              DataCell(
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text('120')), // Add your data here
              DataCell(Text('200')), // Add your data here
              DataCell(Text('')), // Add your data here
            ]),
            DataRow(cells: [
              DataCell(Text('Sale')),
              DataCell(Text('')), // Add your data here
              DataCell(Text('')), // Add your data here
              DataCell(Text('')), // Add your data here
            ]),
            DataRow(cells: [
              DataCell(Text('Remaining',
                  style: TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text('')), // Add your data here
              DataCell(Text('')), // Add your data here
              DataCell(Text('')), // Add your data here
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: themeDefault,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Accounting'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            children: [
              DateHeader(),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100, // Reduced width
                    height: 100, // Reduced height
                    child: _createPieChart(context),
                  ),
                  const SizedBox(width: 30), // Increased width for more padding
                  _createPieLegends(),
                ],
              ),

              _createDashboard(),
              // overall total
            ],
          ),
        ),
      ),
    );
  }
}
