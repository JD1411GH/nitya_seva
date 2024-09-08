import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:intl/intl.dart';

class Serve extends StatefulWidget {
  final LadduServe? serve;

  Serve({this.serve});

  @override
  _ServeState createState() => _ServeState();
}

class _ServeState extends State<Serve> {
  List<TextEditingController> _controllersPushpanjali = [];
  List<TextEditingController> _controllersOthers = [];
  TextEditingController _controllerNote = TextEditingController();
  TextEditingController _controllerTitle = TextEditingController();

  int _totalLadduPacks = 0;
  List<String> _otherSevas = ["Others", "Missing"];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    List<int?> ticketAmounts =
        Const().ticketAmounts.map((e) => e['amount']).toList();

    // default populate the controllers
    _controllersPushpanjali =
        List.generate(ticketAmounts.length, (index) => TextEditingController());
    _controllersOthers =
        List.generate(_otherSevas.length, (index) => TextEditingController());

    // in edit mode, prefill all the controllers
    if (widget.serve != null) {
      // assuming that all sequences are correct

      // controllers for pushpanjali
      for (int i = 0; i < widget.serve!.packsPushpanjali.length; i++) {
        int divider = Const().ticketAmounts[i]['ladduPacks']!;
        int value = widget.serve!.packsPushpanjali[i].values.first ~/ divider;
        _controllersPushpanjali[i].text =
            value.toString(); // assuming that there is only one key-value pair
      }

      // controllers for other sevas
      for (int i = 0; i < widget.serve!.packsOthers.length; i++) {
        _controllersOthers[i].text = widget.serve!.packsOthers[i].values.first
            .toString(); // assuming that there is only one key-value pair
      }

      // controller for title and note
      _controllerTitle.text = widget.serve!.title;
      _controllerNote.text = widget.serve!.note;
    } else {
      // formulate title for the slot
      final now = DateTime.now();
      final dayOfWeek = DateFormat('EEEE').format(now);
      final cutoff = Const().morningCutoff;
      if (now.isBefore(cutoff)) {
        _controllerTitle.text = '$dayOfWeek Morning';
      } else {
        _controllerTitle.text = '$dayOfWeek Evening';
      }
    }

    _calculateTotalLadduPacks();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  void _calculateTotalLadduPacks() {
    _totalLadduPacks = 0;
    for (int i = 0; i < _controllersPushpanjali.length; i++) {
      if (_controllersPushpanjali[i].text.isNotEmpty) {
        int multiplier = Const().ticketAmounts[i]['ladduPacks']!;
        _totalLadduPacks +=
            (int.tryParse(_controllersPushpanjali[i].text)! * multiplier);
      }
    }
    for (int i = 0; i < _controllersOthers.length; i++) {
      _totalLadduPacks += int.tryParse(_controllersOthers[i].text) ?? 0;
    }
  }

  Widget _createTable() {
    List<int?> ticketAmounts =
        Const().ticketAmounts.map((e) => e['amount']).toList();

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

        // Table rows for pushpanjali
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
                    child: Text('Seva ${ticketAmounts[i]}'),
                  ),
                ),
              ),

              // number of tickets
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: TextField(
                      controller: _controllersPushpanjali[i],
                      onChanged: (value) {
                        setState(() {
                          _calculateTotalLadduPacks();
                        });
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

              // number of laddu packs
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: _controllersPushpanjali[i].text.isEmpty
                        ? Text("0")
                        : Text((int.parse(_controllersPushpanjali[i].text) *
                                Const().ticketAmounts[i]['ladduPacks']!)
                            .toString()),
                  ),
                ),
              ),
            ],
          ),

        // Table rows for Others and Missing
        for (String seva in _otherSevas)
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
                    child: Text('$seva'),
                  ),
                ),
              ),

              // empty tickets cell
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(''),
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
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _calculateTotalLadduPacks();
                        });
                      },
                      decoration: InputDecoration(
                        border:
                            OutlineInputBorder(), // Add border around the text field
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                      ),
                      controller: _controllersOthers[_otherSevas.indexOf(seva)],
                    ),
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
            // title
            Padding(
              padding: const EdgeInsets.all(
                  8.0), // Adjust the padding value as needed
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Seva slot',
                ),
                controller: _controllerTitle,
              ),
            ),

            // table of entries
            _createTable(),

            SizedBox(height: 16.0), // Add space between children

            // total laddu packs
            Text(
              "Total laddu packs = $_totalLadduPacks",
              style: TextStyle(
                fontSize: 20.0, // Increase the font size
                fontWeight: FontWeight.bold, // Make the text bold
              ),
              textAlign: TextAlign.center, // Center the text
            ),

            SizedBox(height: 16.0), // Add space between children

            // note
            TextField(
              onChanged: (value) {
                // Handle the changes in the text field
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                hintText: 'Enter a note', // Add a hint text to the text field
              ),
              controller: _controllerNote,
            ),

            SizedBox(height: 16.0), // Add space between children

            // serve button
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_totalLadduPacks == 0) {
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      List<Map<String, int>> packsPushpanjali = [];
                      List<Map<String, int>> packsOthers = [];

                      List<int?> ticketAmounts = Const()
                          .ticketAmounts
                          .map((e) => e['amount'])
                          .toList();

                      for (int i = 0; i < _controllersPushpanjali.length; i++) {
                        if (_controllersPushpanjali[i].text.isEmpty) {
                          packsPushpanjali
                              .add({ticketAmounts[i]!.toString(): 0});
                          continue;
                        }
                        packsPushpanjali.add({
                          ticketAmounts[i]!.toString():
                              int.tryParse(_controllersPushpanjali[i].text)! *
                                  Const().ticketAmounts[i]['ladduPacks']!
                        });
                      }
                      for (int i = 0; i < _controllersOthers.length; i++) {
                        packsOthers.add({
                          _otherSevas[i]:
                              int.tryParse(_controllersOthers[i].text) ?? 0
                        });
                      }

                      DateTime now = DateTime.now();
                      LadduServe ladduDist = LadduServe(
                        timestamp: now,
                        user: await Const().getUserName(),
                        packsPushpanjali: packsPushpanjali,
                        packsOthers: packsOthers,
                        note: _controllerNote.text,
                        title: _controllerTitle.text,
                      );

                      DateTime session = await FB().readLatestLadduSession();
                      await FB().addLadduServe(session, ladduDist);

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.pop(context);
                    },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(widget.serve != null ? 'Update' : 'Serve'),
            ),
          ],
        ),
      ),
    );
  }
}
