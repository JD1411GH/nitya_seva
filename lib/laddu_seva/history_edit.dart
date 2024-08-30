import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/log.dart';

class HistoryEdit extends StatefulWidget {
  final DateTime startSession;

  HistoryEdit({required this.startSession});

  @override
  _HistoryEditState createState() => _HistoryEditState();
}

class _HistoryEditState extends State<HistoryEdit> {
  String _title = 'Edit';
  ListTile _returnWidget = ListTile(
    title: Text('Return'),
    leading: const Icon(Icons.undo),
    onTap: () {
      // Add your return functionality here
    },
  );

  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    String startSession =
        '${widget.startSession.day}/${widget.startSession.month}/${widget.startSession.year}';

    _title = '$startSession';

    LadduReturn lr = await FB().readLadduReturnStatus(widget.startSession);
    if (lr.count > 0) {
      _title +=
          ' - ${lr.timestamp.day}/${lr.timestamp.month}/${lr.timestamp.year}';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: TextStyle(fontSize: 16.0), // Adjust the font size as needed
        ),
      ),
      body: RefreshIndicator(
          onRefresh: _refresh,

          // here a ListView is used to allow the content to be scrollable and refreshable.
          // If you use ListView.builder inside this, then the ListView here can be removed.
          child: Column(
            children: [
              // New widget added before Log
              _returnWidget,
              Divider(),
              Log(session: widget.startSession),
            ],
          )),
    );
  }
}
