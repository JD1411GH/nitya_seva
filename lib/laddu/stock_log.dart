import 'package:flutter/material.dart';

class StockLog extends StatefulWidget {
  @override
  _StockLogState createState() => _StockLogState();
}

class _StockLogState extends State<StockLog> {
  Future<void> _refresh() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laddu stock log'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [Text("Stock"), Text("data")],
          ),
        ),
      ),
    );
  }
}
