import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/stock_add.dart';
import 'package:garuda/fb.dart';
import 'package:synchronized/synchronized.dart';

class StockPage extends StatefulWidget {
  final String stall;

  const StockPage({super.key, required this.stall});

  @override
  State<StockPage> createState() => _StockPageState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_StockPageState> templateKey = GlobalKey<_StockPageState>();

class _StockPageState extends State<StockPage> {
  final _lockInit = Lock();

  int _preparedLamps = 0;
  int _unpreparedLamps = 0;
  int _wicks = 0;
  int _gheePackets = 0;
  int _oilCans = 0;

  @override
  void initState() {
    super.initState();

    FBL().listenForChange("deepotsava",
        FBLCallbacks(onChange: (String changeType, dynamic data) async {
      print("$changeType: $data");
    }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      List<DeepamStock> stocks = await FBL().getStocks(widget.stall);
      _preparedLamps = 0;
      _unpreparedLamps = 0;
      _wicks = 0;
      _gheePackets = 0;
      _oilCans = 0;

      stocks.forEach((stock) {
        _preparedLamps += stock.preparedLamps;
        _unpreparedLamps += stock.unpreparedLamps;
        _wicks += stock.wicks;
        _gheePackets += stock.gheePackets;
        _oilCans += stock.oilCans;
      });
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  void callbackAdd(DeepamStock stock) {
    setState(() {
      _preparedLamps += stock.preparedLamps;
      _unpreparedLamps += stock.unpreparedLamps;
      _wicks += stock.wicks;
      _gheePackets += stock.gheePackets;
      _oilCans += stock.oilCans;
    });
  }

  void _createAddStockPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StockAdd(
            stall: widget.stall, callbacks: StockCallbacks(add: callbackAdd)),
      ),
    );
  }

  Widget _createStock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Prepared lamps: $_preparedLamps'),
          Text('Unprepared lamps: $_unpreparedLamps'),
          Text('Wicks: $_wicks'),
          Text('Ghee packets: $_gheePackets'),
          Text('Oil cans: $_oilCans'),
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
          return _createStock();
        }
      },
    );
  }
}
