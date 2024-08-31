import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/toaster.dart';

String selectedPurpose = "Others";

class AddEditStockDialog extends StatefulWidget {
  final bool edit;
  final LadduStock? stock;
  final DateTime? session;

  AddEditStockDialog({required this.edit, this.stock, this.session});

  @override
  _AddEditStockDialogState createState() => _AddEditStockDialogState();
}

class _AddEditStockDialogState extends State<AddEditStockDialog> {
  String from = "";
  int procured = 0;
  bool isLoading = false;
  String sessionName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.stock != null) {
      from = widget.stock!.from;
      procured = widget.stock!.count;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.edit ? Text('Edit Stock') : Text('Add Stock'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // text input for collected from
            TextFormField(
              decoration: InputDecoration(labelText: 'From'),
              onChanged: (value) {
                from = value;
              },
              controller: TextEditingController(
                text: widget.edit ? widget.stock!.from : '',
              ),
            ),

            // text input for packs procured
            TextFormField(
              decoration: InputDecoration(labelText: 'Packs procured'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) procured = int.parse(value);
              },
              controller: TextEditingController(
                text: widget.edit ? widget.stock!.count.toString() : '',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a valid number';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a value greater than 0';
                }
                return null;
              },
            ),

            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: [
        // delete button
        if (widget.edit)
          ElevatedButton(
            onPressed: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirmation'),
                    content: Text('Are you sure you want to delete?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                setState(() {
                  isLoading = true;
                });

                DateTime session =
                    widget.session ?? await FB().readLatestLadduSession();
                await FB().deleteLadduStock(session, widget.stock!);

                setState(() {
                  isLoading = false;
                });

                Navigator.pop(context);
              }
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set the background color to red
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
          ),

        // cancel button
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),

        // add/edit stock button
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
              });

              String username = await Const().getUserName();

              LadduStock stockNew;
              if (widget.edit) {
                stockNew = LadduStock(
                  timestamp: widget.stock!.timestamp,
                  user: widget.stock!.user,
                  from: from,
                  count: procured,
                );
              } else {
                stockNew = LadduStock(
                  timestamp: DateTime.now(),
                  user: username,
                  from: from,
                  count: procured,
                );
              }

              DateTime session =
                  widget.session ?? await FB().readLatestLadduSession();
              bool status;

              if (widget.edit) {
                status = await FB().editLadduStock(session, stockNew);
              } else {
                status = await FB().addLadduStock(session, stockNew);
              }

              setState(() {
                isLoading = false;
              });

              if (status) {
                Toaster().info("Added successfully");
              } else {
                Toaster().error("Add failed");
              }

              Navigator.pop(context);
            }
          },
          child: Text(widget.edit ? 'Update' : 'Add'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),
      ],
    );
  }
}

Future<void> addEditStock(BuildContext context,
    {bool edit = false, LadduStock? stock = null, DateTime? session}) async {
  showDialog(
    context: context,
    builder: (context) {
      return AddEditStockDialog(edit: edit, stock: stock, session: session);
    },
  );
}

class AddEditDistDialog extends StatefulWidget {
  final bool edit;
  final LadduDist? dist;
  final DateTime? session;

  AddEditDistDialog({required this.edit, this.dist, this.session});

  @override
  _AddEditDistDialogState createState() => _AddEditDistDialogState();
}

class _AddEditDistDialogState extends State<AddEditDistDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerNote = TextEditingController();
  int count = 0;
  String note = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.dist != null) {
      _controllerNote.text = widget.dist!.note;
      count = widget.dist!.count;
      note = widget.dist!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          widget.edit ? Text("Edit served packs") : Text('Serve laddu packs'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // drop down for purpose
            _getPurposeDropDown(context, defaultPurpose: widget.dist?.purpose),

            // count field
            TextFormField(
              decoration: InputDecoration(labelText: 'Packs served'),
              keyboardType: TextInputType.number,
              onChanged: (String value) {
                if (value.isNotEmpty) count = int.parse(value);
              },
              validator: (value) {
                if (value == null || value.isEmpty || value == '0') {
                  return 'Please enter a count';
                }
                return null;
              },
              controller: TextEditingController(
                text: widget.edit ? widget.dist!.count.toString() : '',
              ),
            ),

            // note field
            TextFormField(
              decoration: InputDecoration(labelText: 'Note'),
              controller: _controllerNote,
              onChanged: (String value) {
                note = value;
              },
            ),

            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),

      // action buttons
      actions: <Widget>[
        // delete button
        if (widget.edit)
          ElevatedButton(
            onPressed: () async {
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirmation'),
                    content: Text('Are you sure you want to delete?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Return false
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Return true
                        },
                        child: Text('Confirm'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                setState(() {
                  isLoading = true;
                });

                DateTime session = await FB().readLatestLadduSession();
                await FB().deleteLadduDist(session, widget.dist!);

                setState(() {
                  isLoading = false;
                });

                Navigator.pop(context);
              }
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Set the background color to red
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
          ),

        // cancel button
        ElevatedButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),

        // serve button
        ElevatedButton(
          child: Text(widget.edit ? 'Update' : 'OK'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
              });

              if (count > 0) {
                DateTime session =
                    widget.session ?? await FB().readLatestLadduSession();

                // validate against availability
                List<LadduStock> stocks = await FB().readLadduStocks(session);
                List<LadduDist> dists = await FB().readLadduDists(session);

                int total_procured = 0;
                for (var stock in stocks) {
                  total_procured += stock.count;
                }

                int total_distributed = 0;
                for (var dist in dists) {
                  total_distributed += dist.count;
                }

                int available = total_procured - total_distributed;
                if (count > available) {
                  Toaster().error("Not available");
                } else {
                  String username = await Const().getUserName();

                  LadduDist distNew;
                  if (widget.edit) {
                    distNew = LadduDist(
                      timestamp: widget.dist!.timestamp,
                      user: username,
                      purpose: selectedPurpose,
                      count: count,
                      note: note,
                    );
                  } else {
                    distNew = LadduDist(
                      timestamp: DateTime.now(),
                      user: username,
                      purpose: selectedPurpose,
                      count: count,
                      note: note,
                    );
                  }

                  bool status;
                  if (widget.edit) {
                    status = await FB().editLadduDist(session, distNew);
                  } else {
                    status = await FB().addLadduDist(session, distNew);
                  }

                  if (status) {
                    _controllerNote.clear();
                    Toaster().info("Laddu Distributed");
                  } else {
                    Toaster().error("ERROR");
                  }
                }

                setState(() {
                  isLoading = false;
                });
              }

              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),
      ],
    );
  }
}

Future<void> addEditDist(BuildContext context,
    {bool edit = false, LadduDist? dist = null, DateTime? session}) async {
  showDialog(
    context: context,
    builder: (context) {
      return AddEditDistDialog(edit: edit, dist: dist, session: session);
    },
  );
}

Future<void> returnStock(BuildContext context) async {
  DateTime session = await FB().readLatestLadduSession();

  List<LadduStock> stocks = await FB().readLadduStocks(session);
  stocks.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  List<LadduDist> dists = await FB().readLadduDists(session);
  dists.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  if (stocks.isEmpty) {
    Toaster().error("No stock available");
    return;
  }

  DateTime lastEntry = stocks.last.timestamp;
  if (dists.isNotEmpty && dists.last.timestamp.isAfter(lastEntry)) {
    lastEntry = dists.last.timestamp;
  }

  // sum of all stocks
  int totalStock =
      stocks.fold(0, (previousValue, element) => previousValue + element.count);

  // sum of all distributions
  int totalDist =
      dists.fold(0, (previousValue, element) => previousValue + element.count);

  int remaining = totalStock - totalDist;

  await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return ReturnStockDialog(
        session: session,
        totalStock: totalStock,
        totalDist: totalDist,
        remaining: remaining,
      );
    },
  );
}

class ReturnStockDialog extends StatefulWidget {
  final DateTime session;
  final int totalStock;
  final int totalDist;
  int remaining;
  String returnedTo;
  int returnCount = 0;

  ReturnStockDialog({
    required this.session,
    required this.totalStock,
    required this.totalDist,
    required this.remaining,
    this.returnedTo = '',
  });

  @override
  _ReturnStockDialogState createState() => _ReturnStockDialogState();
}

class _ReturnStockDialogState extends State<ReturnStockDialog> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.returnCount = widget.remaining;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Return laddu stock'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Total laddu packs procured: ${widget.totalStock.toString()}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Total laddu packs served: ${widget.totalDist.toString()}'),
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Returned to',
                ),
                onChanged: (value) {
                  widget.returnedTo = value;
                },
              ),
            ),
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller:
                    TextEditingController(text: widget.remaining.toString()),
                decoration: InputDecoration(
                  labelText: 'Packs returned',
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) widget.returnCount = int.parse(value);
                },
              ),
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text('Cancel'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _confirm,
          child: Text('Confirm'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          ),
        ),
      ],
    );
  }

  Future<void> _confirm() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.returnCount > widget.remaining) {
      Toaster().error("Not available");
      setState(() {
        _isLoading = false;
      });
      return;
    } else if (widget.returnCount < widget.remaining) {
      DateTime session = await FB().readLatestLadduSession();

      await FB().addLadduDist(
          session,
          LadduDist(
              timestamp: DateTime.now(),
              user: "auto",
              purpose: "Missing",
              count: widget.remaining - widget.returnCount,
              note: "Return count less than remaining packs"));
    }

    String username = await Const().getUserName();

    await FB().returnLadduStock(
        widget.session,
        LadduReturn(
            timestamp: DateTime.now(),
            count: widget.returnCount,
            to: widget.returnedTo,
            user: username));

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop(true);
  }
}

Widget _getPurposeDropDown(BuildContext context, {String? defaultPurpose}) {
  List<String> Purposes =
      Const().ticketAmounts.map((e) => "Seva ${e.toString()}").toList();

  Purposes.add("Others");
  Purposes.add("Missing");

  return DropdownButtonFormField<String>(
    value: defaultPurpose ?? 'Others',
    decoration: InputDecoration(labelText: 'Purpose'),
    items: Purposes.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (String? newValue) {
      selectedPurpose = newValue ?? 'Others';
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a purpose';
      }
      return null;
    },
  );
}
