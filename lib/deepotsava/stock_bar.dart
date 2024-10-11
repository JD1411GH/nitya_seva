import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/availability.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/stock_page.dart';

class StockBar extends StatefulWidget {
  final String stall;

  const StockBar({super.key, required this.stall});

  @override
  State<StockBar> createState() => _StockBarState();
}

GlobalKey<_StockBarState> stockBarKey = GlobalKey<_StockBarState>();

class _StockBarState extends State<StockBar> {
  // initializing the label variables
  int _preparedLamps = 0;
  int _unpreparedLamps = 0;

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
            callbackAdd(stock, localUpdate: false);
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
            serveLamps(sale, localUpdate: false);
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

      // reset the availability bar variables
      _currentStock = 0;

      stocks.forEach((stock) {
        // update the label variables
        _preparedLamps += stock.preparedLamps;
        _unpreparedLamps += stock.unpreparedLamps;

        // update the availability bar variables
        _currentStock += stock.preparedLamps + stock.unpreparedLamps;
      });

      // update the availability bar variables for sales
      sales.forEach((sale) {
        _currentStock -= sale.count;
      });
    });
  }

  void serveLamps(DeepamSale sale, {bool localUpdate = false}) {
    setState(() {
      _currentStock -= sale.count;
    });

    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  void callbackAdd(DeepamStock stock, {bool localUpdate = false}) {
    setState(() {
      // update the label variables
      _preparedLamps += stock.preparedLamps;
      _unpreparedLamps += stock.unpreparedLamps;

      // update the availability bar variables
      _currentStock += (stock.preparedLamps + stock.unpreparedLamps);
    });

    // prevent double refresh from FB
    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StockPage(
                                  stall: widget.stall,
                                )));
                  },
                  child: Availability(
                      stall: widget.stall,
                      currentStock: _currentStock,
                      fullStock:
                          (_preparedLamps + _unpreparedLamps).toDouble()))),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => StockPage(
          //                   stall: widget.stall,
          //                 )));
          //   },
          //   style: ElevatedButton.styleFrom(
          //     shape: CircleBorder(),
          //     padding: EdgeInsets.all(10),
          //   ),
          //   child: Icon(Icons.app_registration),
          // ),
        ],
      ),
    );
  }
}
