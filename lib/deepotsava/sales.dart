import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/deepotsava/log.dart';
import 'package:garuda/deepotsava/hmi.dart';
import 'package:garuda/deepotsava/dashboard.dart';
import 'package:garuda/deepotsava/stock_bar.dart';
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
  }

  Future<void> _refresh() async {
    if (mounted) {
      await dashboardKey.currentState!.refresh();
      await logKey.currentState!.refresh();
      await stockBarKey.currentState!.refresh();
    }

    setState(() {});
  }

  Future<void> serveLamps(DeepamSale sale) async {
    if (mounted) {
      dashboardKey.currentState!.addLampsServed(sale);
      logKey.currentState!.addLog(sale, localUpdate: true);
      stockBarKey.currentState!.serveLamps(sale, localUpdate: true);
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
          title: Text('${widget.stall} Deepam Sales'),
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,

          // here a ListView is used to allow the content to be scrollable and refreshable.
          // If you use ListView.builder inside this, then the ListView here can be removed.
          child: ListView(
            children: [
              DateHeader(),
              StockBar(key: stockBarKey, stall: widget.stall),
              Dashboard(key: dashboardKey, stall: widget.stall),
              HMI(
                  stall: widget.stall,
                  callbacks: HMICallbacks(add: serveLamps)),
              Log(key: logKey, stall: widget.stall),
            ],
          ),
        ),
      ),
    );
  }
}
