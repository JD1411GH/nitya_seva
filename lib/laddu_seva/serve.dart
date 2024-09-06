import 'package:flutter/material.dart';

class Serve extends StatefulWidget {
  @override
  _ServeState createState() => _ServeState();
}

class _ServeState extends State<Serve> {
  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _createTable() {
    Table table = Table(
      columnWidths: {
        0: FixedColumnWidth(150.0),
        1: FixedColumnWidth(80.0),
        2: FlexColumnWidth(),
      },
      children: [],
    );

    // header row
    TableRow header = TableRow(
      children: [
        TableCell(
          child: Center(
            child: Text(
              'Seva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Center(
            child: Text(
              'Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TableCell(
          child: Center(
            child: Text(
              'Packs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
    table.children.add(header);

    // seva ticket row
    TableRow row = TableRow(
      children: [
        TableCell(
          child: Center(
            child: Text(
              'Laddu',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        TableCell(
          child: Center(
            child: Text(
              '0',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        TableCell(
          child: Center(
            child: Text(
              '0',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
    table.children.add(row);

    return table;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serve laddu'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        child: ListView(
          children: [
            _createTable(),
          ],
        ),
      ),
    );
  }
}
