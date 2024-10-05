import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/availability.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/stock_dialog.dart';
import 'package:synchronized/synchronized.dart';

class StockPage extends StatefulWidget {
  final String stall;

  const StockPage({super.key, required this.stall});

  @override
  State<StockPage> createState() => _StockPageState();
}

GlobalKey<_StockPageState> stockPageKey = GlobalKey<_StockPageState>();

class _StockPageState extends State<StockPage> {
  final _lockInit = Lock();

  // initializing the label variables
  int _preparedLamps = 0;
  int _unpreparedLamps = 0;
  int _plates = 0;
  int _wicks = 0;
  int _gheePackets = 0;
  int _oilCans = 0;

  // initializing the availability bar variables
  double _currentStock = 0;

  DateTime _localUpdateTime = DateTime.now();

  @override
  void initState() {
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

    // subscribe for updates on sales
    FBL().listenForChange(
        "deepotsava/${widget.stall}/sales",
        FBLCallbacks(
          // callback for adding a new sale
          add: (dynamic data) async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            DeepamSale sale = DeepamSale.fromJson(map);
            serveLamps(sale);
          },

          // callback for editing a sale
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refresh() async {
    List<DeepamStock> stocks = await FBL().getStocks(widget.stall);
    List<DeepamSale> sales = await FBL().getSales(widget.stall);

    setState(() {
      // reset the label variables
      _preparedLamps = 0;
      _unpreparedLamps = 0;
      _plates = 0;
      _wicks = 0;
      _gheePackets = 0;
      _oilCans = 0;

      // reset the availability bar variables
      _currentStock = 0;

      stocks.forEach((stock) {
        // update the label variables
        _preparedLamps += stock.preparedLamps;
        _unpreparedLamps += stock.unpreparedLamps;
        _plates += stock.plates;
        _wicks += stock.wicks;
        _gheePackets += stock.gheePackets;
        _oilCans += stock.oilCans;

        // update the availability bar variables
        _currentStock += stock.preparedLamps + stock.unpreparedLamps;
      });

      // update the availability bar variables for sales
      sales.forEach((sale) {
        _currentStock -= sale.count;
      });
    });
  }

  void serveLamps(DeepamSale sale) {
    _localUpdateTime = DateTime.now();
    setState(() {
      _currentStock -= sale.count;
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

      // update the availability bar variables
      _currentStock += stock.preparedLamps + stock.unpreparedLamps;
    });

    // prevent double refresh from FB
    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  void _createAddStockPage(BuildContext context) {
    showStockAddDialog(context, widget.stall, StockCallbacks(add: callbackAdd));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text widgets inside a scrollable area
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Prepared lamps: $_preparedLamps'),
                      Text('Unprepared lamps: $_unpreparedLamps'),
                      Text('Plates: $_plates'),
                      Text('Wicks: $_wicks'),
                      Text('Ghee packets: $_gheePackets'),
                      Text('Oil cans: $_oilCans'),
                    ],
                  ),
                ),
              ),

              // Button row outside the scrollable area
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        _createAddStockPage(context);
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
              ),
            ],
          ),

          Spacer(),

          // availability bar
          Column(
            children: [
              Expanded(
                  child: SizedBox(
                      width: 50,
                      child: Availability(
                        stall: widget.stall,
                        currentStock: _currentStock,
                        fullStock: _preparedLamps.toDouble() +
                            _unpreparedLamps.toDouble(),
                      ))),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text("Availability")),
            ],
          ),
        ],
      ),
    );
    ;
  }
}
