import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/stock_dialog.dart';
import 'package:garuda/theme.dart';

class StockPage extends StatefulWidget {
  final String stall;

  const StockPage({Key? key, required this.stall}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  // initializing the label variables
  int _preparedLamps = 0;
  int _unpreparedLamps = 0;
  int _plates = 0;
  int _wicks = 0;
  int _gheePackets = 0;
  int _oilCans = 0;

  DateTime _localUpdateTime = DateTime.now();

  @override
  initState() {
    super.initState();

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

          // callback for editing a stock
          edit: () async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            await refresh();
            setState(() {});
          },
        ));
  }

  Future<void> refresh() async {
    List<DeepamStock> stocks = await FBL().getStocks(widget.stall);

    setState(() {
      // reset the label variables
      _preparedLamps = 0;
      _unpreparedLamps = 0;
      _plates = 0;
      _wicks = 0;
      _gheePackets = 0;
      _oilCans = 0;

      stocks.forEach((stock) {
        // update the label variables
        _preparedLamps += stock.preparedLamps;
        _unpreparedLamps += stock.unpreparedLamps;
        _plates += stock.plates;
        _wicks += stock.wicks;
        _gheePackets += stock.gheePackets;
        _oilCans += stock.oilCans;
      });
    });
  }

  void callbackAdd(DeepamStock stock, {bool localUpdate = false}) {
    setState(() {
      // update the label variables
      _preparedLamps += stock.preparedLamps;
      _unpreparedLamps += stock.unpreparedLamps;
      _plates += stock.plates;
      _wicks += stock.wicks;
      _gheePackets += stock.gheePackets;
      _oilCans += stock.oilCans;
    });

    // prevent double refresh from FB
    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Select theme based on the value of stall
    ThemeData selectedTheme;
    if (widget.stall == 'RRG') {
      selectedTheme = themeRRG;
    } else if (widget.stall == 'RKC') {
      selectedTheme = themeRKC;
    } else {
      selectedTheme = themeDefault;
    }

    return Theme(
      data: selectedTheme,
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
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: null,
                  ),
                  IconButton(
                    icon: Icon(Icons.undo),
                    onPressed: null,
                  ),
                ],
              ),

              // Text widgets inside a scrollable area
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prepared lamps: $_preparedLamps',
                          style: selectedTheme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Unprepared lamps: $_unpreparedLamps',
                          style: selectedTheme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Plates: $_plates',
                          style: selectedTheme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Wicks: $_wicks',
                          style: selectedTheme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Ghee packets: $_gheePackets',
                          style: selectedTheme.textTheme.bodyMedium,
                        ),
                        Text(
                          'Oil cans: $_oilCans',
                          style: selectedTheme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
