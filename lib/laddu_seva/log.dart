import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class Log extends StatefulWidget {
  const Log({super.key});

  @override
  State<Log> createState() => _LogState();
}

// hint: LogKey.currentState!.refresh();
final GlobalKey<_LogState> LogKey = GlobalKey<_LogState>();

class _LogState extends State<Log> {
  final _lockInit = Lock();

  List<ListTile> _logItems = [];

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      _logItems = [];
      DateTime allotment = await FB().readLatestLadduAllotment();

      List<LadduStock> stocks = await FB().readLadduStocks(allotment);
      for (LadduStock stock in stocks) {
        _logItems.add(ListTile(
          title: Text(DateFormat('dd-MM-yyyy HH:mm').format(stock.timestamp)),
          leading: const Icon(Icons.add),
          trailing: Container(
            padding: EdgeInsets.all(8.0), // Add padding around the text
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.black, width: 2.0), // Add a border
              borderRadius:
                  BorderRadius.circular(12.0), // Make the border circular
            ),
            child: Text(
              stock.count.toString(),
              style: TextStyle(fontSize: 24.0), // Increase the font size
            ),
          ),
          subtitle: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Sevakarta: ${stock.user}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Laddu packs collected: ${stock.count}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Collected from: ${stock.from}'),
              ),
            ],
          ),
        ));
      }

      List<LadduDist> dists = await FB().readLadduDists(allotment);
      for (LadduDist stock in dists) {
        _logItems.add(ListTile(
          title: Text(DateFormat('dd-MM-yyyy HH:mm').format(stock.timestamp)),
          leading: const Icon(Icons.remove),
          trailing: Container(
            padding: EdgeInsets.all(8.0), // Add padding around the text
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.black, width: 2.0), // Add a border
              borderRadius:
                  BorderRadius.circular(12.0), // Make the border circular
            ),
            child: Text(
              stock.count.toString(),
              style: TextStyle(fontSize: 24.0), // Increase the font size
            ),
          ),
          subtitle: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Sevakarta: ${stock.user}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Laddu packs served: ${stock.count}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Purpose: ${stock.purpose}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Note: ${stock.note}'),
              ),
            ],
          ),
        ));
      }

      _logItems.sort((a, b) {
        return b.title.toString().compareTo(a.title.toString());
      });
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getListView() {
    return Column(
      children: List.generate(_logItems.length * 2 - 1, (index) {
        if (index.isEven) {
          return _logItems[index ~/ 2];
        } else {
          return Divider();
        }
      }),
    );
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
          return _getListView();
        }
      },
    );
  }
}
