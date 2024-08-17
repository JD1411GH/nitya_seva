import 'package:flutter/material.dart';
import 'package:garuda/laddu_seva/laddu_dash.dart';

class LadduMain extends StatefulWidget {
  @override
  _LadduSevaState createState() => _LadduSevaState();
}

class _LadduSevaState extends State<LadduMain> {
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
        child: ListView(
          children: [
            LadduDash(),
          ],
        ),
      ),
    );
  }
}
