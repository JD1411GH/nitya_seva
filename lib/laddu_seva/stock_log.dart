import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:intl/intl.dart';

class StockLog extends StatefulWidget {
  @override
  _StockLogState createState() => _StockLogState();
}

class _StockLogState extends State<StockLog> {
  List<LadduStock> logs = [];

  Future<void> _futureInit() async {
    DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime endDate = DateTime.now();
    logs = await FB().readLadduStocksByDateRange(startDate, endDate);
    if (logs.isNotEmpty) {
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
  }

  Future<void> _refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getListViewStock() {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        String formattedDate =
            DateFormat('dd-MM-yyyy').format(logs[index].timestamp);
        String formattedTime =
            DateFormat('HH:mm').format(logs[index].timestamp);

        return Column(
          children: [
            ListTile(
              title: Text("Date: $formattedDate \t Time: $formattedTime"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Sevakarta: ${logs[index].user}"),
                  Text('Laddu packets added: ${logs[index].count}'),
                ],
              ),
            ),
            Divider(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<void>(
          future: _futureInit(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              if (logs.isEmpty) {
                return Center(
                    child: Text(
                  "No laddu stocks procured \nin this month",
                  style: TextStyle(
                      fontSize: 20.0), // Adjust the font size as needed
                ));
              } else {
                return _getListViewStock();
              }
            }
          },
        ),
      ),
    );
  }
}
