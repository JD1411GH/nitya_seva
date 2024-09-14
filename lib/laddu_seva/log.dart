import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/laddu_calc.dart';
import 'package:garuda/laddu_seva/serve.dart';
import 'package:garuda/laddu_seva/utils.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class Log extends StatefulWidget {
  final DateTime? session;

  const Log({super.key, this.session});

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

      DateTime session = widget.session ?? await FB().readLatestLadduSession();

      List<LadduStock> stocks = await FB().readLadduStocks(session);
      for (LadduStock stock in stocks) {
        _logItems.add(ListTile(

            // title
            title: Text(
              DateFormat('dd-MM-yyyy HH:mm:ss').format(stock.timestamp),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),

            // leading icon
            leading: Icon(
              Icons.add,
              color: Colors.green[800],
            ),

            // body
            subtitle: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sevakarta: ${stock.user}',
                    style: TextStyle(color: Colors.green[900]),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Laddu packs collected: ${stock.count}',
                    style: TextStyle(color: Colors.green[900]),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Collected from: ${stock.from}',
                    style: TextStyle(color: Colors.green[900]),
                  ),
                ),
              ],
            ),

            // the count
            trailing: Container(
              padding: EdgeInsets.all(8.0), // Add padding around the text
              decoration: BoxDecoration(
                color:
                    Colors.green[100], // Change background color to light green
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
              if (widget.session == null) {
                addEditStock(context, edit: true, stock: stock);
              } else {
                addEditStock(context,
                    edit: true, stock: stock, session: session);
              }
            }));
      }

      // add the logs for laddu serves
      List<LadduServe> serves = await FB().readLadduServes(session);
      for (LadduServe serve in serves) {
        ListTile tile = ListTile(
            // title - careful changing this, as the tiles are sorted based on this
            title: Text(
              DateFormat('dd-MM-yyyy HH:mm:ss').format(serve.timestamp),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0, // Adjust the font size as needed
              ),
            ),

            // add or remove icon
            leading: const Icon(Icons.remove),

            // trailer : total count
            trailing: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CalculateTotalLadduPacksServed(serve).toString(),
                      style: TextStyle(
                        fontSize: 24.0, // Increase font size
                        fontWeight: FontWeight.bold, // Make text bold
                      ),
                    ),
                    Text("Total"),
                  ],
                ),
              ),
            ),

            // all details
            subtitle: Column(
              children: [
                // slot name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.black, // Dark background color
                    child: Text(
                      serve.title,
                      style: TextStyle(
                        color: Colors.white, // Light text color
                      ),
                    ),
                  ),
                ),

                // sevakarta
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sevakarta: ',
                          style: TextStyle(
                            fontSize:
                                16.0, // Replace with your desired font size
                            color:
                                Colors.black, // Replace with your desired color
                          ),
                        ),
                        TextSpan(
                          text: '${serve.user}',
                          style: TextStyle(
                            fontFamily:
                                'YourFontFamily', // Replace with your font family
                            fontSize:
                                16.0, // Replace with your desired font size
                            color:
                                Colors.black, // Replace with your desired color
                            fontStyle: FontStyle.italic, // Make the text italic
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // edit on tap
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Serve(
                          serve: serve,
                        )),
              );
            });

        // heading for laddu packs served
        (tile.subtitle as Column).children.add(Align(
              alignment: Alignment.centerLeft,
              child: Text('Laddu packs served: '),
            ));

        // all pushpanjali tickets
        for (int i = 0; i < serve.packsPushpanjali.length; i++) {
          if (serve.packsPushpanjali[i].values.first != 0) {
            (tile.subtitle as Column).children.add(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '    Seva ${serve.packsPushpanjali[i].keys.first}: ${serve.packsPushpanjali[i].values.first}',
                  ),
                ));
          }
        }

        // other seva tickets
        for (int i = 0; i < serve.packsOtherSeva.length; i++) {
          if (serve.packsOtherSeva[i].values.first != 0) {
            (tile.subtitle as Column).children.add(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '    ${serve.packsOtherSeva[i].keys.first}: ${serve.packsOtherSeva[i].values.first}',
                  ),
                ));
          }
        }

        // all misc
        for (int i = 0; i < serve.packsMisc.length; i++) {
          if (serve.packsMisc[i].values.first != 0) {
            (tile.subtitle as Column).children.add(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '    ${serve.packsMisc[i].keys.first}: ${serve.packsMisc[i].values.first}',
                  ),
                ));
          }
        }

        // balance
        (tile.subtitle as Column).children.add(Align(
              alignment: Alignment.centerLeft,
              child: Text('Balance: ${serve.balance}'),
            ));

        // note
        if (serve.note.isNotEmpty)
          (tile.subtitle as Column).children.add(Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  color: Colors.yellow,
                  child: Text('Note: ${serve.note}'),
                ),
              ));

        _logItems.add(tile);
      }

      _logItems.sort((a, b) {
        String titleA = (a.title as Text).data ?? '';
        String titleB = (b.title as Text).data ?? '';

        DateFormat format = DateFormat("dd-MM-yyyy hh:mm:ss");
        DateTime dateA = format.parse(titleA);
        DateTime dateB = format.parse(titleB);

        return dateB.compareTo(dateA);
      });
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    if (mounted) {
      setState(() {});
    }
  }

  Widget _getListView() {
    if (_logItems.isEmpty) {
      return Center(
        child: Text(
          'No entries',
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
