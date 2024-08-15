import 'package:flutter/material.dart';

class LadduPage extends StatefulWidget {
  @override
  _LadduPageState createState() => _LadduPageState();
}

class _LadduPageState extends State<LadduPage> {
  Future<void> _refresh() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RefreshIndicator Example'),
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
