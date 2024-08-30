import 'package:flutter/material.dart';

class HistoryEdit extends StatefulWidget {
  final DateTime startSession;

  HistoryEdit({required this.startSession});

  @override
  _HistoryEditState createState() => _HistoryEditState();
}

class _HistoryEditState extends State<HistoryEdit> {
  Future<void> _refresh() async {
    // Simulate a network call
    await Future.delayed(Duration(seconds: 2));
  }

  List<Widget> _getFixedItems() {
    String startSession =
        '${widget.startSession.day}/${widget.startSession.month}/${widget.startSession.year}';
    return [
      ListTile(
        title: Text('Start Session: $startSession'),
      ),
    ];
  }

  List<Widget> _getEditableItems() {
    return [
      ListTile(
        title: Text('End Session'),
        subtitle: Text(''),
        trailing: Icon(Icons.edit),
      ),
      ListTile(
        title: Text('Stock'),
        subtitle: Text(''),
        trailing: Icon(Icons.edit),
      ),
      ListTile(
        title: Text('Distribution'),
        subtitle: Text(''),
        trailing: Icon(Icons.edit),
      ),
    ];
  }

  List<Widget> _getButtons() {
    return [
      ElevatedButton(
        onPressed: () {},
        child: Text('Save'),
      ),
    ];
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
            ..._getFixedItems(),
            ..._getEditableItems(),
            ..._getButtons(),
          ],
        ),
      ),
    );
  }
}
