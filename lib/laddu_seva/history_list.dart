import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/history_edit.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/history_edit.dart';
import 'package:synchronized/synchronized.dart';

class HistoryList extends StatefulWidget {
  const HistoryList({super.key});

  @override
  State<HistoryList> createState() => _HistoryListState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_HistoryListState> HistoryListKey =
    GlobalKey<_HistoryListState>();

class _HistoryListState extends State<HistoryList> {
  final _lockInit = Lock();

  List<Widget> _logs = [];
  Color _primaryColor = Const().getRandomLightColor();

  Future<void> _futureInit([DateTime? month]) async {
    await _lockInit.synchronized(() async {
      if (month == null) {
        // Get the current month
        month = DateTime.now();
      }

      final startDate = DateTime(month!.year, month!.month, 1);
      final endDate = DateTime.now();
      List<DateTime> allotments =
          await FB().readLadduSessions(startDate, endDate);
      allotments.sort((a, b) => b.compareTo(a));

      _logs.clear();
      for (DateTime session in allotments) {
        List<LadduStock> stocks = await FB().readLadduStocks(session);
        stocks.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        List<LadduDist> dists = await FB().readLadduDists(session);
        dists.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        DateTime startSession = session;
        DateTime endSession = dists.last.timestamp;
        if (dists.isNotEmpty &&
            stocks.last.timestamp.isAfter(dists.last.timestamp)) {
          endSession = stocks.last.timestamp;
        }

        String title =
            "${startSession.day}/${startSession.month}/${startSession.year} - ${endSession.day}/${endSession.month}/${endSession.year}";

        List<String> body = [];

        int totalStock = 0;
        for (LadduStock stock in stocks) {
          totalStock += stock.count;
        }
        body.add("Total laddu packs procured = $totalStock");

        int totalDist = 0;
        for (LadduDist dist in dists) {
          totalDist += dist.count;
        }

        Map<String, int> purposeSum = {};
        dists.forEach((dist) {
          if (purposeSum.containsKey(dist.purpose)) {
            purposeSum[dist.purpose] = purposeSum[dist.purpose]! + dist.count;
          } else {
            purposeSum[dist.purpose] = dist.count;
          }
        });

        body.add("Laddu packs served for:");
        purposeSum.forEach((purpose, count) {
          if (purpose == "Missing") {
            body.add("Missing laddu packs = $count");
          } else {
            body.add("    $purpose = $count");
          }
        });

        LadduReturn lr = await FB().readLadduReturnStatus(session);
        if (lr.count > 0) {
          body.add("Laddu packs returned = ${totalStock - totalDist}");
        } else {
          body.add("---Service in progress---");
        }

        _logs.add(
          ListTile(
            // title
            title: Container(
              color: _primaryColor, // Set your desired color here
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0), // Adjust the left padding as needed
                child: Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold), // Make the title bold
                ),
              ),
            ),

            // body
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: body.map((e) => Text(e)).toList(),
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HistoryEdit(
                          startSession: startSession,
                        )),
              );
            },
          ),
        );
      }
    });
  }

  Future<void> refresh(DateTime month) async {
    await _futureInit(month);
    setState(() {});
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
            children: _logs,
          );
        }
      },
    );
  }
}