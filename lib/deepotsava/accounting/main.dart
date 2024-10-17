import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/accounting/pie.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/theme.dart';

class Accounting extends StatefulWidget {
  @override
  _AccountingState createState() => _AccountingState();
}

class _AccountingState extends State<Accounting> {
  @override
  initState() {
    super.initState();

    refresh();
  }

  Future<void> refresh() async {
    await pieKey.currentState?.refresh();
    setState(() {});
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
          onRefresh: refresh,
          child: ListView(
            children: [
              DateHeader(),

              const SizedBox(height: 20),

              // card for pie chart
              Pie(key: pieKey),

              Card(child: _createDashboard()),
              // overall total
            ],
          ),
        ),
      ),
    );
  }
}
