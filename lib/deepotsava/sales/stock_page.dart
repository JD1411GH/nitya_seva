import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/sales/stock_dialog.dart';
import 'package:garuda/theme.dart';
import 'package:intl/intl.dart';

class StockPage extends StatefulWidget {
  final String stall;

  const StockPage({Key? key, required this.stall}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late ThemeData _selectedTheme;

  // initializing the label variables
  int _preparedLamps = 0;
  int _unpreparedLamps = 0;
  int _plates = 0;
  int _wicks = 0;
  int _gheePackets = 0;
  int _oilCans = 0;

  // prevent double refresh
  DateTime _localUpdateTime = DateTime.now();

  // list of stocks added
  List<ListTile> _stockTiles = [];

  @override
  initState() {
    super.initState();

    // Select theme based on the value of stall
    if (widget.stall == 'RRG') {
      _selectedTheme = themeRRG;
    } else if (widget.stall == 'RKC') {
      _selectedTheme = themeRKC;
    } else {
      _selectedTheme = themeDefault;
    }

    refresh();

    // subscribe for updates on stocks
    FBL().listenForChange(
        "deepotsava/${widget.stall}/stocks",
        FBLCallbacks(
          // callback for adding a new stock
          add: (dynamic data) async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            DeepamStock stock = DeepamStock.fromJson(map);
            callbackAdd(stock);
          },

          // callback for delete a new stock
          delete: (dynamic data) async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            // Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            // DeepamStock stock = DeepamStock.fromJson(map);
            // callbackAdd(stock);
          },

          // callback for editing a stock
          edit: () async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            await refresh();
            if (!mounted) return;
            setState(() {});
          },
        ));
  }

  Future<void> refresh() async {
    List<DeepamStock> stocks = await FBL().getStocks(widget.stall);

    if (!mounted) return;
    setState(() {
      // reset the label variables
      _preparedLamps = 0;
      _unpreparedLamps = 0;
      _plates = 0;
      _wicks = 0;
      _gheePackets = 0;
      _oilCans = 0;

      // reset the list of stock entries
      _stockTiles = [];

      stocks.forEach((stock) {
        // update the label variables
        _preparedLamps += stock.preparedLamps;
        _unpreparedLamps += stock.unpreparedLamps;
        _plates += stock.plates;
        _wicks += stock.wicks;
        _gheePackets += stock.gheePackets;
        _oilCans += stock.oilCans;

        // add a tile for the new entry
        _addStockTile(stock);
      });

      // sort the list of stock entries by timestamp
      _stockTiles.sort((a, b) {
        String timeA = a.title.toString();
        String timeB = b.title.toString();
        return timeB.compareTo(timeA);
      });
    });
  }

  void callbackAdd(DeepamStock stock, {bool localUpdate = false}) {
    if (!mounted) return;
    setState(() {
      // update the label variables
      _preparedLamps += stock.preparedLamps;
      _unpreparedLamps += stock.unpreparedLamps;
      _plates += stock.plates;
      _wicks += stock.wicks;
      _gheePackets += stock.gheePackets;
      _oilCans += stock.oilCans;

      // add a tile for the new entry
      _addStockTile(stock);
    });

    // prevent double refresh from FB
    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  void _addStockTile(DeepamStock stock) {
    String time = DateFormat('HH:mm').format(stock.timestamp);

    _stockTiles.add(ListTile(
      // title: timetamp
      title: Text(
        '${time}',
        style: _selectedTheme.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),

      // body
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Sevakarta: ${stock.user}"),
          if (stock.preparedLamps > 0)
            Text(
              'Prepared lamps: ${stock.preparedLamps}',
            ),
          if (stock.unpreparedLamps > 0)
            Text(
              'Unprepared lamps: ${stock.unpreparedLamps}',
            ),
          if (stock.plates > 0)
            Text(
              'Plates: ${stock.plates}',
            ),
          if (stock.wicks > 0)
            Text(
              'Wicks: ${stock.wicks}',
            ),
        ],
      ),

      // trailing
      trailing: Column(
        children: [
          CircleAvatar(
            child: Text(
              '${stock.preparedLamps + stock.unpreparedLamps}',
            ),
          ),
          Text(
            'Lamps',
          ),
        ],
      ),
    ));

    // sort the list of stock entries by timestamp
    _stockTiles.sort((a, b) {
      String timeA = a.title.toString();
      String timeB = b.title.toString();
      return timeB.compareTo(timeA);
    });
  }

  Widget _createStockSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prepared lamps: $_preparedLamps',
                style: _selectedTheme.textTheme.bodyMedium,
              ),
              Text(
                'Unprepared lamps: $_unpreparedLamps',
                style: _selectedTheme.textTheme.bodyMedium,
              ),
              Text(
                'Plates: $_plates',
                style: _selectedTheme.textTheme.bodyMedium,
              ),
              Text(
                'Wicks: $_wicks',
                style: _selectedTheme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _selectedTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Deepam Stock'),
        ),
        body: RefreshIndicator(
          onRefresh: refresh,
          child:
              // Button row outside the scrollable area
              ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showStockAddDialog(context, widget.stall,
                          StockCallbacks(add: callbackAdd));
                    },
                  ),

                  // return button
                  IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: null,
                  ),
                ],
              ),

              // Text widgets inside a scrollable area
              _createStockSummary(context),

              // List of stock entries
              Text(
                "All stock entries",
                style: _selectedTheme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              Divider(),
              Column(
                children:
                    _stockTiles.expand((tile) => [tile, Divider()]).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
