import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:synchronized/synchronized.dart';

class LadduSummary extends StatefulWidget {
  const LadduSummary({super.key});

  @override
  State<LadduSummary> createState() => _LadduSummaryState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_LadduSummaryState> LadduSummaryKey =
    GlobalKey<_LadduSummaryState>();

class _LadduSummaryState extends State<LadduSummary> {
  final _lockInit = Lock();

  int total_procured = 0;
  int total_distributed = 0;
  int procured_today = 0;
  int distributed_today = 0;

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      total_procured = await FB().readLadduStockTotal();
      total_distributed = await FB().readLadduDistSum();

      // get today's stock
      List<LadduStock> stocks =
          await FB().readLadduStocks(date: DateTime.now());
      procured_today = 0;
      for (var stock in stocks) {
        procured_today += stock.count;
      }

      // get today's distribution
      List<LadduDist> dists = await FB().readLadduDists(date: DateTime.now());
      distributed_today = 0;
      for (var dist in dists) {
        distributed_today += dist.count;
      }
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  void restock(int procured) {
    total_procured += procured;
    procured_today += procured;
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Total laddu packs remaining = ${total_procured - total_distributed}"),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Laddu packs procured today = $procured_today"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      "Laddu packs distributed today = $distributed_today"),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
