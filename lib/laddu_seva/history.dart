import 'package:flutter/material.dart';
import 'package:garuda/laddu_seva/history_list.dart';
import 'package:garuda/laddu_seva/history_header.dart';

class History extends StatefulWidget {
  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  Future<void> _refresh() async {
    await HistoryListKey.currentState!.refresh(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seva history'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        child: ListView(
          children: [
            HistoryHeader(key: HistoryHeaderKey),
            HistoryList(key: HistoryListKey),
          ],
        ),
      ),
    );
  }
}
