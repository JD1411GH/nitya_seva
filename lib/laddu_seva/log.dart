import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/laddu_calc.dart';
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
      DateTime session = await FB().readLatestLadduSession();

      // display log only if not returned
      LadduReturn status = await FB().readLadduReturnStatus(session);
      if (status.count == 0) {
        return;
      }

      List<LadduStock> stocks = await FB().readLadduStocks(session);
      for (LadduStock stock in stocks) {
        _logItems.add(ListTile(
            title: Text(
                DateFormat('dd-MM-yyyy HH:mm:ss').format(stock.timestamp),
                style: TextStyle(fontWeight: FontWeight.bold)),
            leading: const Icon(Icons.add),

            // body
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

            // the count
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

            // on tap
            onTap: () {
              addEditStock(context, edit: true, stock: stock);
            }));
      }

      List<LadduDist> dists = await FB().readLadduDists(session);
      for (LadduDist dist in dists) {
        _logItems.add(ListTile(
            title: Text(
              DateFormat('dd-MM-yyyy HH:mm:ss').format(dist.timestamp),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
                dist.count.toString(),
                style: TextStyle(fontSize: 24.0), // Increase the font size
              ),
            ),
            subtitle: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sevakarta: ${dist.user}'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Laddu packs served: ${dist.count}'),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Purpose: ${dist.purpose}'),
                ),
                if (dist.note.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Note: ${dist.note}'),
                  ),
              ],
            ),

            // edit on tap
            onTap: () {
              addEditDist(context, edit: true, dist: dist);
            }));
      }

      _logItems.sort((a, b) {
        String titleA = (a.title as Text).data ?? '';
        String titleB = (b.title as Text).data ?? '';
        return titleB.compareTo(titleA);
      });
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  Widget _getListView() {
    if (_logItems.isEmpty) {
      return Center(
        child: Text(
          'Click above buttons to start',
          style: TextStyle(
            color: Colors.red,
            fontSize: 20.0, // Adjust the font size as needed
          ),
        ),
      );
    } else {
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
