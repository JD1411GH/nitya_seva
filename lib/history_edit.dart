import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';

class HistoryEdit extends StatefulWidget {
  final DateTime startSession;

  HistoryEdit({required this.startSession});

  @override
  _HistoryEditState createState() => _HistoryEditState();
}

class _HistoryEditState extends State<HistoryEdit> {
  String _endSession = '';
  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    LadduReturn lr = await FB().readLadduReturnStatus(widget.startSession);
    if (lr.count > 0) {
      _endSession =
          '${lr.timestamp.day}/${lr.timestamp.month}/${lr.timestamp.year}';
    }

    setState(() {});
  }

  List<Widget> _getFixedItems() {
    String startSession =
        '${widget.startSession.day}/${widget.startSession.month}/${widget.startSession.year}';

    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Start Session: $startSession',
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('End Session: $_endSession'),
      ),
    ];
  }

  List<Widget> _getEditableItems() {
    List<ListTile> items = [];

    Const().ticketAmounts.forEach((amount) {
      items.add(ListTile(
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Seva ticket $amount'),
            ),
            Expanded(
              flex: 3,
              child: TextField(),
            ),
          ],
        ),
      ));
    });

    ["Others", "Missing"].forEach((value) {
      items.add(ListTile(
        title: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('$value'),
            ),
            Expanded(
              flex: 3,
              child: TextField(),
            ),
          ],
        ),
      ));
    });

    return items;
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
