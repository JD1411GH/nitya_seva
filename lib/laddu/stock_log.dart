import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu/laddu_datatypes.dart';

class StockLog extends StatefulWidget {
  @override
  _StockLogState createState() => _StockLogState();
}

class _StockLogState extends State<StockLog> {
  List<LadduStock> logs = [];

  Widget _getListViewStock() {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("HI"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Laddu stock log'),
        ),
        body: _getListViewStock());
  }
}
