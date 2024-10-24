import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/deepotsava/sales/log.dart';
import 'package:garuda/deepotsava/sales/hmi.dart';
import 'package:garuda/deepotsava/sales/dashboard.dart';
import 'package:garuda/deepotsava/sales/stock_bar.dart';
import 'package:garuda/deepotsava/sales/summary.dart';
import 'package:garuda/theme.dart';

class Sales extends StatefulWidget {
  final String stall;

  Sales({required this.stall});

  @override
  _SalesState createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  @override
  initState() {
    super.initState();

    FBL().listenForChange(
        "deepotsava/${widget.stall}/stocks",
        FBLCallbacks(add: (data) {
          Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
          DeepamStock stock = DeepamStock.fromJson(map);
          addStock(stock);
        }, edit: () {
          _refresh();
        }, delete: (data) {
          Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
          DeepamStock stock = DeepamStock.fromJson(map);
          deleteStock(stock);
        }));
  }

  Future<void> _refresh() async {
    await dashboardKey.currentState!.refresh();
    await logKey.currentState!.refresh();
    await stockBarKey.currentState!.refresh();
    await summaryKey.currentState!.refresh();

    if (!mounted) return;
    setState(() {});
  }

  void addStock(DeepamStock stock) {
    summaryKey.currentState!.addStock(stock);
  }

  void deleteStock(DeepamStock stock) {
    summaryKey.currentState!.deleteStock(stock);
  }

  Future<void> addServedLamps(DeepamSale sale) async {
    if (sale.paymentMode == 'Discard') {
      logKey.currentState!.addLog(sale, localUpdate: true);
      stockBarKey.currentState!.discardLamps(sale, localUpdate: true);
      summaryKey.currentState!.discardLamps(sale);
    } else {
      dashboardKey.currentState!.addLampsServed(sale);
      logKey.currentState!.addLog(sale, localUpdate: true);
      stockBarKey.currentState!.serveLamps(sale, localUpdate: true);
      summaryKey.currentState!.addSale(sale);
    }
  }

  void editServedLamps(DeepamSale sale) {
    if (sale.paymentMode == 'Discard') {
      stockBarKey.currentState!.refresh();
      logKey.currentState!.refresh();
      summaryKey.currentState!.refresh();
    } else {
      summaryKey.currentState!.editSale();
    }
  }

  void deleteServedLamps(DeepamSale sale) {
    if (sale.paymentMode == 'Discard') {
    } else {
      summaryKey.currentState!.deleteSale(sale);
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
          title: Text('${widget.stall} Deepam Seva'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,

          // here a ListView is used to allow the content to be scrollable and refreshable.
          // If you use ListView.builder inside this, then the ListView here can be removed.
          child: ListView(
            children: [
              DateHeader(),
              StockBar(key: stockBarKey, stall: widget.stall),
              HMI(
                  stall: widget.stall,
                  callbacks: HMICallbacks(add: addServedLamps)),
              Log(
                  key: logKey,
                  stall: widget.stall,
                  callbacks: LogCallbacks(
                      edit: editServedLamps, delete: deleteServedLamps)),
              Summary(key: summaryKey, stall: widget.stall),
            ],
          ),
        ),
      ),
    );
  }
}
