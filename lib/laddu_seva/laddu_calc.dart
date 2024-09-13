import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/toaster.dart';

String selectedPurpose = "Others";
bool selectedPurposeChanged = false;

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

              DateTime session;
              bool status;

              if (widget.edit) {
                session = widget.session ?? await FB().readLatestLadduSession();
                status = await FB().editLadduStock(session, stockNew);
              } else {
                // check if session is already running
                session = await FB().readLatestLadduSession();
                LadduReturn lr = await FB().readLadduReturnStatus(session);

                if (lr.count >= 0) {
                  // session is closed. create new one.
                  session = await FB().addLadduSession();
                }

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

int _calculateTotalLadduPacksServed(LadduServe serve) {
  int total = 0;

  serve.packsPushpanjali.forEach((element) {
    total += element.values.first;
  });

  serve.packsOthers.forEach((element) {
    total += element.values.first;
  });

  return total;
}

Future<void> returnStock(BuildContext context) async {
  DateTime session = await FB().readLatestLadduSession();

  List<LadduStock> stocks = await FB().readLadduStocks(session);
  stocks.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  List<LadduServe> serves = await FB().readLadduServes(session);
  serves.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  if (stocks.isEmpty) {
    Toaster().error("No stock available");
    return;
  }

  DateTime lastEntry = stocks.last.timestamp;
  if (serves.isNotEmpty && serves.last.timestamp.isAfter(lastEntry)) {
    lastEntry = serves.last.timestamp;
  }

  // sum of all stocks
  int totalStock =
      stocks.fold(0, (previousValue, element) => previousValue + element.count);

  // sum of all distributions
  int totalServe = 0;
  serves.forEach((serve) {
    totalServe += _calculateTotalLadduPacksServed(serve);
  });

  int remaining = totalStock - totalServe;

  await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return ReturnStockDialog(
        session: session,
        totalStock: totalStock,
        totalServe: totalServe,
        remaining: remaining,
      );
    },
  );
}

class ReturnStockDialog extends StatefulWidget {
  final DateTime session;
  final int totalStock;
  final int totalServe;
  int remaining;
  String returnedTo;
  int returnCount = 0;

  ReturnStockDialog({
    required this.session,
    required this.totalStock,
    required this.totalServe,
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
                  'Total laddu packs served: ${widget.totalServe.toString()}'),
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
      // TODO
      // await FB().addLadduServe(
      //     widget.session,
      //     LadduServe(
      //         timestamp: DateTime.now(),
      //         user: "auto",
      //         purpose: "Missing",
      //         count: widget.remaining - widget.returnCount,
      //         note: "Return count less than remaining packs"));
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
  List<int?> pushpanjaliTickets =
      Const().pushpanjaliTickets.map((e) => e['amount']).toList();
  List<String> Purposes =
      pushpanjaliTickets.map((e) => "Seva ${e.toString()}").toList();

  Purposes.add("Others");
  Purposes.add("Missing");

  // if there was no change in the dropdown, set the selected purpose to default
  if (!selectedPurposeChanged) {
    selectedPurpose = defaultPurpose ?? 'Others';
  }

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
      selectedPurposeChanged = true;
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please select a purpose';
      }
      return null;
    },
  );
}
