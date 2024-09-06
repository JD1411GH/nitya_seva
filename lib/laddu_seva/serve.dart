import 'package:flutter/material.dart';

class Serve extends StatefulWidget {
  @override
  _ServeState createState() => _ServeState();
}

class _ServeState extends State<Serve> {
  List<int> _ladduPacks = [];

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
        // seva name
        TableCell(
          child: Center(
            child: Text(
              'Seva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // number of tickets
        TableCell(
          child: Center(
            child: Text(
              'Tickets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // number of laddu packs
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
    _ladduPacks.add(0);
    TableRow row = TableRow(
      children: [
        // seva name
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Center(
            child: Text(
              'Pushpanjali 400',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),

        // number of tickets
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Center(
            child: TextField(
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _ladduPacks[0] = int.tryParse(value) ?? 0;
                });
              },
            ),
          ),
        ),

        // number of laddu packs
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Center(
            child: Text(
              _ladduPacks[0].toString(),
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
