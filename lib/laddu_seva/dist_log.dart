import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:intl/intl.dart';

class DistributionLog extends StatefulWidget {
  @override
  _DistributionLogState createState() => _DistributionLogState();
}

class _DistributionLogState extends State<DistributionLog> {
  List<LadduDistAccumulated> logs = [];

  Future<void> _futureInit() async {
    DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime endDate = DateTime.now();
    List<LadduDist> logsAll =
        await FB().readLadduDistsByDateRange(startDate, endDate);
    if (logsAll.isNotEmpty) {
      logsAll.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    logs.clear();
    logsAll.forEach((log) {
      String logDate = DateFormat('yyyy-MM-dd').format(log.timestamp);
      if (logs.isEmpty) {
        logs.add(LadduDistAccumulated(
            date: logDate,
            count: log.count,
            users: [log.user],
            notes: [log.note]));
      } else {
        if (logs.last.date == logDate) {
          logs.last.count += log.count;

          if (logs.last.users.contains(log.user) == false) {
            logs.last.users.add(log.user);
          }

          if (log.note.isNotEmpty) {
            logs.last.notes.add(log.note);
          }
        } else {
          // new date
          logs.add(LadduDistAccumulated(
              date: logDate,
              count: log.count,
              users: [log.user],
              notes: [log.note]));
        }
      }
    });
  }

  Future<void> _refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getListViewDist() {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        String formattedDate = logs[index].date;

        return Column(
          children: [
            ListTile(
              title: Text("Date: $formattedDate"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laddu packs distributed: ${logs[index].count}'),
                  Text('Sevakartas: ${logs[index].users.join(", ")}'),
                  Text('Notes: ${logs[index].notes.join(", ")}'),
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
                  "No laddu distributed \nin this month",
                  style: TextStyle(
                      fontSize: 20.0), // Adjust the font size as needed
                ));
              } else {
                return _getListViewDist();
              }
            }
          },
        ),
      ),
    );
  }
}
