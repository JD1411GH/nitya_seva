import 'package:flutter/material.dart';
import 'package:garuda/const.dart';

class Serve extends StatefulWidget {
  @override
  _ServeState createState() => _ServeState();
}

class _ServeState extends State<Serve> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    _controllers = List.generate(
        Const().ticketAmounts.length, (index) => TextEditingController());

    setState(() {});
  }

  Widget _createTable() {
    return Table(
      columnWidths: {
        0: FixedColumnWidth(
            150.0), // Set the desired width for the first column
      },
      children: [
        // table header
        TableRow(
          children: [
            // seva header
            TableCell(
              child: Center(
                child: Text(
                  'Seva',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0, // Increase the font size as needed
                  ),
                ),
              ),
            ),

            // tickets header
            TableCell(
              child: Center(
                child: Text(
                  'Tickets',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0, // Increase the font size as needed
                  ),
                ),
              ),
            ),

            // packs header
            TableCell(
              child: Center(
                child: Text(
                  'Packs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0, // Increase the font size as needed
                  ),
                ),
              ),
            ),
          ],
        ),

        // seva rows
        for (int i = 0; i < Const().ticketAmounts.length; i++)
          TableRow(
            children: [
              // seva name
              TableCell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Pushpanjali ${Const().ticketAmounts[i]}'),
                ),
              ),

              // ticket count
              TableCell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: _controllers[i],
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // pack count
              TableCell(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_controllers[i].text),
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serve laddu'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            _createTable(),
          ],
        ),
      ),
    );
  }
}
