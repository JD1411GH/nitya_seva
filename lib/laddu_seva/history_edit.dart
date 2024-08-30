import 'package:flutter/material.dart';

class HistoryEdit extends StatefulWidget {
  @override
  _HistoryEditState createState() => _HistoryEditState();
}

class _HistoryEditState extends State<HistoryEdit> {
  Future<void> _refresh() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit laddu Seva'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        child: ListView(
          children: [
            Text('body'),
          ],
        ),
      ),
    );
  }
}
