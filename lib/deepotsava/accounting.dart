import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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

  PieChartSectionData _createPieSection(pieValue, pieText) {
    return PieChartSectionData(
      color: Colors.orange,
      value: pieValue.toDouble(),
      title: pieText,
      radius: 40,
      titleStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: countModePercentage['UPI']! > 9
            ? Colors.white
            : Theme.of(context).textTheme.bodyLarge!.color,
      ),
      titlePositionPercentageOffset:
          countModePercentage['UPI']! > 9 ? 0.5 : 1.2,
    );
  }

  Widget _createPieChart(BuildContext context) {
    if (countModePercentage['UPI'] == 0 &&
        countModePercentage['Cash'] == 0 &&
        countModePercentage['Card'] == 0 &&
        countModePercentage['Gift'] == 0) {
      return const Text("");
    }

    double radius = 40;

    return PieChart(
      PieChartData(
        sections: [
          // UPI
          _createPieSection(
              countModePercentage['UPI']!.toDouble(), '${countMode['UPI']}'),

          // cash
          PieChartSectionData(
            color: Colors.green,
            value: countModePercentage['Cash']!.toDouble(),
            title: '${countMode['Cash']}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countModePercentage['Cash']! > 9
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            titlePositionPercentageOffset:
                countModePercentage['Cash']! > 9 ? 0.5 : 1.2,
          ),

          // card
          PieChartSectionData(
            color: Colors.blue,
            value: countModePercentage['Card']!.toDouble(),
            title: '${countMode['Card']}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countModePercentage['Card']! > 9
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            titlePositionPercentageOffset:
                countModePercentage['Card']! > 9 ? 0.5 : 1.2,
          ),

          // gift
          PieChartSectionData(
            color: Colors.purple,
            value: countModePercentage['Gift']!.toDouble(),
            title: '${countMode['Gift']}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countModePercentage['Gift']! > 9
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            titlePositionPercentageOffset:
                countModePercentage['Gift']! > 9 ? 0.5 : 1.2,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 8,
      ),
    );
  }

  Widget _createPieLegends() {
    if (countModePercentage['UPI'] == 0 &&
        countModePercentage['Cash'] == 0 &&
        countModePercentage['Card'] == 0) {
      return const Text("");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _createLegendItem(Colors.orange, 'UPI'),
        _createLegendItem(Colors.green, 'Cash'),
        _createLegendItem(Colors.blue, 'Card'),
        _createLegendItem(Colors.purple, 'Gift'),
      ],
    );
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
