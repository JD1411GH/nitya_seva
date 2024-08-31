import 'package:flutter/material.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/log.dart';
import 'package:intl/intl.dart';

class HistoryEdit extends StatefulWidget {
  final DateTime startSession;

  HistoryEdit({required this.startSession});

  @override
  _HistoryEditState createState() => _HistoryEditState();
}

class _HistoryEditState extends State<HistoryEdit> {
  String _title = 'Edit';

  Widget _returnWidget = Text("");

  @override
  initState() {
    super.initState();

    FB().listenForChange("ladduSeva",
        FBCallbacks(onChange: (String changeType, dynamic data) {
      _refresh();
    }));
  }

  Future<void> _refresh() async {
    // formulate the title
    String startSession =
        '${widget.startSession.day}/${widget.startSession.month}/${widget.startSession.year}';

    _title = '$startSession';
    LadduReturn lr = await FB().readLadduReturnStatus(widget.startSession);
    String endSession =
        "${lr.timestamp.day}/${lr.timestamp.month}/${lr.timestamp.year}";
    if (lr.count > 0) {
      _title += ' - $endSession';
    }

    // formulate the return widget
    if (lr.count > 0) {
      _returnWidget = ListTile(
        title: Text(
          DateFormat("dd/MM/yyy hh:mm").format(lr.timestamp),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.undo),
        trailing: Container(
          padding: EdgeInsets.all(8.0), // Add padding around the text
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2.0), // Add a border
            borderRadius:
                BorderRadius.circular(12.0), // Make the border circular
          ),
          child: Text(
            lr.count.toString(),
            style: TextStyle(fontSize: 24.0), // Increase the font size
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sevakarta: ${lr.user}'),
            Text('Returned to: ${lr.to}'),
            Text('Laddu packs returned: ${lr.count}'),
          ],
        ),
        onTap: () {
          _onEditReturn(context, lr);
        },
      );
    }

    setState(() {});
  }

  void _onEditReturn(BuildContext context, LadduReturn lr) {
    TextEditingController returnedToController =
        TextEditingController(text: lr.to);
    TextEditingController countController =
        TextEditingController(text: lr.count.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Return'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: returnedToController,
                decoration: InputDecoration(
                  labelText: 'Returned to',
                ),
              ),
              TextFormField(
                controller: countController,
                decoration: InputDecoration(
                  labelText: 'Count',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                await FB().editLadduReturn(
                    widget.startSession,
                    LadduReturn(
                        timestamp: lr.timestamp,
                        to: returnedToController.text,
                        count: int.parse(countController.text),
                        user: lr.user));
                await _refresh();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        child: ListView(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 8.0), // Adjust the value as needed
              child: _returnWidget,
            ),
            Divider(),
            Log(session: widget.startSession),
          ],
        ),
      ),
    );
  }
}
