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

    FBL().listenForChange("deepotsava/${widget.stall}/stocks",
        FBLCallbacks(add: (dynamic data) async {
      // skip refresh if already updated locally
      if (DateTime.now().difference(_localUpdateTime).inSeconds < 2) {
        return;
      }

      Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
      DeepamStock stock = DeepamStock.fromJson(map);
      callbackAdd(stock);
    }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      List<DeepamStock> stocks = await FBL().getStocks(widget.stall);
      List<DeepamSale> sales = await FBL().getSales(widget.stall);

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

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  void serveLamps(DeepamSale sale) {
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

  Widget _createMainWidget() {
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
          return _createMainWidget();
        }
      },
    );
  }
}
