import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/date_header.dart';
import 'package:garuda/deepotsava/log.dart';
import 'package:garuda/deepotsava/stats.dart';
import 'package:garuda/deepotsava/stock.dart';
import 'package:garuda/deepotsava/hmi.dart';
import 'package:garuda/deepotsava/dashboard.dart';
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

    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted) {
      await dashboardKey.currentState?.refresh();
      await logKey.currentState?.refresh();
      await stockPageKey.currentState?.refresh();
    }

    setState(() {});
  }

  Widget _createCardPage() {
    return Card(
      child: SizedBox(
        height: 150.0,
        child: PageView(
          children: [
            StockPage(key: stockPageKey, stall: widget.stall),
            StatsPage(stall: widget.stall),
          ],
        ),
      ),
    );
  }

  Future<void> serveLamps(DeepamSale sale) async {
    if (mounted) {
      dashboardKey.currentState!.addLampsServed(sale);
      logKey.currentState!.addLog(sale);
      stockPageKey.currentState!.serveLamps(sale);
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
              _createCardPage(),
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
