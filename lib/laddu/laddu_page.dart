import 'package:flutter/material.dart';
import 'package:garuda/laddu/dist.dart';
import 'package:garuda/laddu/stock.dart';

class LadduPage extends StatefulWidget {
  @override
  _LadduPageState createState() => _LadduPageState();
}

class _LadduPageState extends State<LadduPage> {
  Widget _stock = Stock();
  Widget _dist = Dist();

  Future<void> _refresh() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Laddu Seva'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _stock,
              _dist,
            ],
          ),
        ),
      ),
    );
  }
}
