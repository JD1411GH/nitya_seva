import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/laddu_seva/utils.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';
import 'package:garuda/toaster.dart';
import 'package:intl/intl.dart';

class Serve extends StatefulWidget {
  final LadduServe? serve;
  final PushpanjaliSlot? slot;

  Serve({this.serve, this.slot});

  @override
  _ServeState createState() => _ServeState();
}

class _ServeState extends State<Serve> {
  List<TextEditingController> _controllersPushpanjali = [];
  List<TextEditingController> _controllersOtherSeva = [];
  List<TextEditingController> _controllerMisc = [];
  TextEditingController _controllerNote = TextEditingController();
  TextEditingController _controllerTitle = TextEditingController();

  int _totalLadduPacks = 0;
  List<String> _misc = ["Miscellaneous"];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    List<int?> pushpanjaliTickets =
        Const().pushpanjaliTickets.map((e) => e['amount']).toList();

    // default populate the controllers
    _controllersPushpanjali = List.generate(
        pushpanjaliTickets.length, (index) => TextEditingController());
    _controllersOtherSeva = List.generate(
        Const().otherSevaTickets.length, (index) => TextEditingController());
    _controllerMisc =
        List.generate(_misc.length, (index) => TextEditingController());

    // in edit mode, prefill all the controllers
    if (widget.serve != null) {
      // assuming that all sequences are correct

      // controllers for pushpanjali
      for (int i = 0; i < widget.serve!.packsOtherSeva.length; i++) {
        int divider = Const().otherSevaTickets[i]['ladduPacks']!;
        int value = widget.serve!.packsOtherSeva[i].values.first ~/ divider;
        _controllersOtherSeva[i].text = value.toString();
      }

      // controllers for other sevas
      for (int i = 0; i < widget.serve!.packsPushpanjali.length; i++) {
        int divider = Const().pushpanjaliTickets[i]['ladduPacks']!;
        int value = widget.serve!.packsPushpanjali[i].values.first ~/ divider;
        _controllersPushpanjali[i].text =
            value.toString(); // assuming that there is only one key-value pair
      }

      // controllers for misc
      for (int i = 0; i < widget.serve!.packsMisc.length; i++) {
        _controllerMisc[i].text = widget.serve!.packsMisc[i].values.first
            .toString(); // assuming that there is only one key-value pair
      }

      // controller for title and note
      _controllerTitle.text = widget.serve!.title;
      _controllerNote.text = widget.serve!.note;
    } else {
      // formulate title for the slot
      _controllerTitle.text = widget.slot!.title;
    }

    _calculateTotalLadduPacks();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  void _calculateTotalLadduPacks() {
    _totalLadduPacks = 0;

    // add all entries for pushpanjali
    for (int i = 0; i < _controllersPushpanjali.length; i++) {
      if (_controllersPushpanjali[i].text.isNotEmpty) {
        int multiplier = Const().pushpanjaliTickets[i]['ladduPacks']!;
        _totalLadduPacks +=
            (int.tryParse(_controllersPushpanjali[i].text)! * multiplier);
      }
    }

    // add all entries for other sevas
    for (int i = 0; i < _controllersOtherSeva.length; i++) {
      if (_controllersOtherSeva[i].text.isNotEmpty) {
        int multiplier = Const().otherSevaTickets[i]['ladduPacks']!;
        _totalLadduPacks +=
            (int.tryParse(_controllersOtherSeva[i].text)! * multiplier);
      }
    }

    // add all entries for misc
    for (int i = 0; i < _controllerMisc.length; i++) {
      _totalLadduPacks += int.tryParse(_controllerMisc[i].text) ?? 0;
    }
  }

  Widget _createTable() {
    List<int?> pushpanjaliTickets =
        Const().pushpanjaliTickets.map((e) => e['amount']).toList();

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
        for (int i = 0; i < Const().pushpanjaliTickets.length; i++)
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
                    child: Text('Seva ${pushpanjaliTickets[i]}'),
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
                      keyboardType:
                          TextInputType.number, // Set keyboard to numeric
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
                                Const().pushpanjaliTickets[i]['ladduPacks']!)
                            .toString()),
                  ),
                ),
              ),
            ],
          ),

        // Table rows for other sevas
        for (int i = 0; i < Const().otherSevaTickets.length; i++)
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
                    child: Text("${Const().otherSevaTickets[i]['name']}"),
                  ),
                ),
              ),

              // number of tickets for other Seva
              TableCell(
                verticalAlignment:
                    TableCellVerticalAlignment.middle, // Center vertically
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: TextField(
                      controller: _controllersOtherSeva[i],
                      keyboardType: TextInputType.number,
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
                    child: _controllersOtherSeva[i].text.isEmpty
                        ? Text("0")
                        : Text((int.parse(_controllersOtherSeva[i].text) *
                                Const().otherSevaTickets[i]['ladduPacks']!)
                            .toString()),
                  ),
                ),
              ),
            ],
          ),

        // Table rows for Others and Missing
        for (String seva in _misc)
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

              // packs cell for misc
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
                      controller: _controllerMisc[_misc.indexOf(seva)],
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _onpressServe() async {
    if (_totalLadduPacks == 0) {
      Toaster().error('No laddu packs entered');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    List<Map<String, int>> packsPushpanjali = [];
    List<Map<String, int>> packsOtherSeva = [];
    List<Map<String, int>> packsMisc = [];

    List<int?> pushpanjaliTickets =
        Const().pushpanjaliTickets.map((e) => e['amount']).toList();

    // pushpanjali
    for (int i = 0; i < _controllersPushpanjali.length; i++) {
      if (_controllersPushpanjali[i].text.isEmpty) {
        packsPushpanjali.add({pushpanjaliTickets[i]!.toString(): 0});
        continue;
      }
      packsPushpanjali.add({
        pushpanjaliTickets[i]!.toString():
            int.tryParse(_controllersPushpanjali[i].text)! *
                Const().pushpanjaliTickets[i]['ladduPacks']!
      });
    }

    // other sevas
    for (int i = 0; i < _controllersOtherSeva.length; i++) {
      // no entries
      if (_controllersOtherSeva[i].text.isEmpty) {
        packsOtherSeva.add({Const().otherSevaTickets[i]['name']: 0});
        continue;
      }

      // add entries
      int mul = Const().otherSevaTickets[i]['ladduPacks']!;
      packsOtherSeva.add({
        Const().otherSevaTickets[i]['name']:
            int.tryParse(_controllersOtherSeva[i].text)! * mul
      });
    }

    // misc
    for (int i = 0; i < _controllerMisc.length; i++) {
      packsMisc.add({_misc[i]: int.tryParse(_controllerMisc[i].text) ?? 0});
    }

    // calculate balance
    int total_procured = 0;
    int total_served = 0;
    DateTime session = await FB().readLatestLadduSession();
    await FB().readLadduStocks(session).then((stocks) {
      for (LadduStock stock in stocks) {
        total_procured += stock.count;
      }
    });
    await FB().readLadduServes(session).then((serves) {
      for (LadduServe serve in serves) {
        total_served += CalculateTotalLadduPacksServed(serve);
      }
    });
    if (widget.serve != null) {
      // in edit mode, remove the previous serve count
      total_served -= CalculateTotalLadduPacksServed(widget.serve!);
    }
    total_served += _totalLadduPacks;

    DateTime now = DateTime.now();
    if (widget.serve != null) {
      now = widget.serve!.timestamp;
    }
    LadduServe ladduServe = LadduServe(
      timestamp: now,
      user: await Const().getUserName(),
      packsPushpanjali: packsPushpanjali,
      packsOtherSeva: packsOtherSeva,
      packsMisc: packsMisc,
      note: _controllerNote.text,
      title: _controllerTitle.text,
      balance: total_procured - total_served,
      slot: widget.slot!,
    );

    if (widget.serve != null) {
      await FB().editLadduServe(session, ladduServe);
    } else {
      await FB().addLadduServe(session, ladduServe);
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pop(context);
  }

  Future<bool?> _createConfirmDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to delete?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Confirm'),
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
              onPressed: _isLoading ? null : _onpressServe,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text(widget.serve != null ? 'Update' : 'Serve'),
            ),

            // delete button
            if (widget.serve != null)
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        bool? confirm = await _createConfirmDialog();

                        if (confirm == true) {
                          setState(() {
                            _isLoading = true;
                          });

                          DateTime session =
                              await FB().readLatestLadduSession();
                          await FB().deleteLadduServe(session, widget.serve!);

                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Set the background color to red
                ),
                child:
                    _isLoading ? CircularProgressIndicator() : Text('Delete'),
              ),
          ],
        ),
      ),
    );
  }
}
