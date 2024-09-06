import 'package:flutter/material.dart';
import 'package:garuda/const.dart';

class Serve extends StatefulWidget {
  @override
  _serve createState() => _serve();
}

class _serve extends State<Serve> {
  List<TableRow> _tableRows = [];

  @override
  initState() {
    super.initState();

    _refresh();
  }

  Future<void> _refresh() async {
    _tableRows.clear();

    // add the seva tickets
    Const().ticketAmounts.forEach((value) {
      _tableRows.add(TableRow(
        children: [
          // label
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Pushpanjali $value",
                  style: TextStyle(
                    fontSize: 18.0, // Increase font size
                  ),
                ),
              ),
            ),
          ),

          // input field - number of tickets
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),

          // number of laddu packs
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '0',
                  style: TextStyle(
                    fontSize: 18.0, // Increase font size
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
    });

    // add others
    ["Others", "Missing"].forEach((value) {
      _tableRows.add(TableRow(
        children: [
          // label
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 18.0, // Increase font size
                  ),
                ),
              ),
            ),
          ),

          // input field - number of tickets (empty)
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox.shrink(), // Empty cell
              ),
            ),
          ),

          // number of laddu packs (TextField)
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '0',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Serve Laddu'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,

        // here a ListView is used to allow the content to be scrollable and refreshable.
        // If you use ListView.builder inside this, then the ListView here can be removed.
        child: ListView(
          children: [
            // table of services
            Padding(
              padding: const EdgeInsets.all(
                  8.0), // Adjust the padding value as needed
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(
                      2), // Adjust the flex value as needed to make the first column wider
                },
                border: null,
                children: [
                  // table header
                  TableRow(
                    children: [
                      Text(
                        'Seva',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0, // Adjust the font size as needed
                        ),
                      ),
                      Text(
                        'Tickets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0, // Adjust the font size as needed
                        ),
                      ),
                      Text(
                        'Packs',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0, // Adjust the font size as needed
                        ),
                      ),
                    ],
                  ),

                  // table rows
                  ..._tableRows,
                ],
              ),
            ),

            // total packs
            SizedBox(
                height: 16.0), // Add some space between the table and the text
            Center(
              child: Text(
                'Total laddu packs = ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0, // Large font size
                ),
              ),
            ),

            // note field
            Padding(
              padding: const EdgeInsets.all(
                  8.0), // Adjust the padding value as needed
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Note',
                ),
              ),
            ),

            // button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // delete button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your delete logic here
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color?>(Colors.red),
                    ),
                    child: Text('Delete'),
                  ),
                ),

                // serve button
                SizedBox(
                    width:
                        10), // Optional: Add some spacing between the buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your serve logic here
                    },
                    child: Text('Serve'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
