import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';
import 'package:intl/intl.dart';

String selectedPurpose = "Others";

Future<void> addEditStock(BuildContext context,
    {bool edit = false, LadduStock? stock = null}) async {
  String from = "";
  int procured = edit ? stock!.count : 0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: edit ? Text('Edit Stock') : Text('Add Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // text input for collected from
            TextField(
              decoration: InputDecoration(labelText: 'From'),
              onChanged: (value) {
                from = value;
              },
              controller: TextEditingController(
                text: edit ? stock!.from : '',
              ),
            ),

            // text input for packs procured
            TextField(
              decoration: InputDecoration(labelText: 'Packs procured'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.isNotEmpty) procured = int.parse(value);
              },
              controller: TextEditingController(
                text: edit ? stock!.count.toString() : '',
              ),
            ),
          ],
        ),
        actions: [
          // delete button
          if (edit)
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
                  DateTime allotment = await FB().readLatestLadduAllotment();
                  await FB().deleteLadduStock(allotment, stock!);
                  Navigator.pop(context);
                } else {
                  // Cancel the action
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
              var u = await LS().read('user_details');
              if (u != null) {
                var uu = jsonDecode(u);
                UserDetails user = UserDetails.fromJson(uu);

                LadduStock stockNew;
                if (edit) {
                  stockNew = LadduStock(
                    timestamp: stock!.timestamp,
                    user: stock.user,
                    from: from,
                    count: procured,
                  );
                } else {
                  stockNew = LadduStock(
                    timestamp: DateTime.now(),
                    user: user.name!,
                    from: from,
                    count: procured,
                  );
                }

                DateTime allotment = await FB().readLatestLadduAllotment();
                bool status;

                if (edit) {
                  status = await FB().editLadduStock(allotment, stockNew);
                } else {
                  status = await FB().addLadduStock(allotment, stockNew);
                }

                if (status) {
                  Toaster().info("Added successfully");
                } else {
                  Toaster().error("Add failed");
                }
              } else {
                Toaster().error("Error");
              }
              Navigator.pop(context);
            },
            child: Text(edit ? 'Update' : 'Add'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> addEditDist(BuildContext context,
    {bool edit = false, LadduDist? dist = null}) async {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerNote = TextEditingController();
  if (edit) {
    _controllerNote.text = dist!.note;
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      int count = edit ? dist!.count : 0;
      String note = edit ? dist!.note : '';

      return AlertDialog(
        title: edit ? Text("Edit served packs") : Text('Serve laddu packs'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // drop down for purpose
              _getPurposeDropDown(context, defaultPurpose: dist?.purpose),

              // count field
              TextFormField(
                decoration: InputDecoration(labelText: 'Packs served'),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  if (value.isNotEmpty) count = int.parse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value == 0) {
                    return 'Please enter a count';
                  }
                  return null;
                },
                controller: TextEditingController(
                  text: edit ? dist!.count.toString() : '',
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
            ],
          ),
        ),

        // action buttons
        actions: <Widget>[
          // delete button
          if (edit)
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
                  DateTime allotment = await FB().readLatestLadduAllotment();
                  await FB().deleteLadduDist(allotment, dist!);
                  Navigator.pop(context);
                } else {
                  // Cancel the action
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
            child: Text(edit ? 'Update' : 'OK'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (count > 0) {
                  String username = await Const().getUserName();

                  LadduDist distNew;
                  if (edit) {
                    distNew = LadduDist(
                      timestamp: dist!.timestamp,
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

                  DateTime allotment = await FB().readLatestLadduAllotment();

                  bool status;
                  if (edit) {
                    status = await FB().editLadduDist(allotment, distNew);
                  } else {
                    status = await FB().addLadduDist(allotment, distNew);
                  }

                  if (status) {
                    _controllerNote.clear();
                    Toaster().info("Laddu Distributed");
                  } else {
                    Toaster().error("ERROR");
                  }
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
    },
  );
}

Future<void> returnStock(BuildContext context) async {
  DateTime allotment = await FB().readLatestLadduAllotment();

  List<LadduStock> stocks = await FB().readLadduStocks(allotment);
  stocks.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  List<LadduDist> dists = await FB().readLadduDists(allotment);
  dists.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  DateTime firstEntry = allotment;

  DateTime lastEntry = stocks.last.timestamp;
  if (dists.last.timestamp.isAfter(lastEntry)) {
    lastEntry = dists.last.timestamp;
  }

  // sum of all stocks
  int totalStock =
      stocks.fold(0, (previousValue, element) => previousValue + element.count);

  // sum of all distributions
  int totalDist =
      dists.fold(0, (previousValue, element) => previousValue + element.count);

  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Are you sure?'),
        content:
            // Summary of the stock and distribution
            Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Start date: ${DateFormat('dd-MM-yyyy').format(firstEntry)}'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'End date: ${DateFormat('dd-MM-yyyy').format(lastEntry)}'),
            ),

            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child:
                  Text('Total laddu packs procured: ${totalStock.toString()}'),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Text('Total laddu packs served: ${totalDist.toString()}'),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laddu packs to return:'),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    (totalStock - totalDist).toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                ),
              ],
            ),

            // confirmation
            SizedBox(height: 8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Do you really want to return the stock?'),
            ),
          ],
        ),

        // confirm and cancel buttons
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FB().returnLadduStock(allotment);
              Navigator.of(context).pop(true);
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );
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
