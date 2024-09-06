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
        0: FixedColumnWidth(150.0), // Set fixed width for the first column
      },
      children: [
        // Table header
        TableRow(
          children: [
            // seva header
            TableCell(
              verticalAlignment:
                  TableCellVerticalAlignment.middle, // Center vertically
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Seva',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Increase font size
                    ),
                  ),
                ),
              ),
            ),

            // tickets header
            TableCell(
              verticalAlignment:
                  TableCellVerticalAlignment.middle, // Center vertically
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Tickets',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Increase font size
                    ),
                  ),
                ),
              ),
            ),

            // packs header
            TableCell(
              verticalAlignment:
                  TableCellVerticalAlignment.middle, // Center vertically
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Packs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Increase font size
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Table rows
        for (int i = 0; i < Const().ticketAmounts.length; i++)
          TableRow(
            children: [
              // seva cell
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Pushpanjali ${Const().ticketAmounts[i]}'),
                  ),
                ),
              ),

              // tickets cell
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: TextField(
                      controller: _controllers[i],
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        border:
                            OutlineInputBorder(), // Add border around the text field
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 8.0), // Reduce vertical height
                      ),
                    ),
                  ),
                ),
              ),

              // packs cell
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(_controllers[i].text),
                  ),
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
