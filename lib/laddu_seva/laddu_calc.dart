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

Future<void> addEditStock(
    BuildContext context, Future<void> Function() callbackRefresh,
    {bool edit = false, LadduStock? stock = null}) async {
  String from = "";
  int procured = 0;

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
                procured = int.parse(value);
              },
              controller: TextEditingController(
                text: edit ? stock!.count.toString() : '',
              ),
            ),
          ],
        ),
        actions: [
          if (edit)
            ElevatedButton(
              onPressed: () async {},
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
                  await callbackRefresh();
                  Toaster().info("Added successfully");
                } else {
                  Toaster().error("Add failed");
                }
              } else {
                Toaster().error("Error");
              }
              Navigator.pop(context);
            },
            child: Text(edit ? 'Save' : 'Add'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> removeStock(
    BuildContext context, Future<void> Function() callbackRefresh) async {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _controllerNote = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      int? count;
      String? note;

      return AlertDialog(
        title: Text('Serve laddu packs'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // drop down for purpose
              _getPurposeDropDown(context),

              // count field
              TextFormField(
                decoration: InputDecoration(labelText: 'Count'),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  count = int.tryParse(value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value == 0) {
                    return 'Please enter a count';
                  }
                  return null;
                },
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
          // cancel button
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),

          // serve button
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (count! > 0) {
                  String username = await Const().getUserName();

                  LadduDist dist = LadduDist(
                    timestamp: DateTime.now(),
                    user: username,
                    purpose: selectedPurpose,
                    count: count ?? 0,
                    note: note ?? '',
                  );

                  DateTime allotment = await FB().readLatestLadduAllotment();
                  bool status = await FB().addLadduDist(allotment, dist);
                  if (status) {
                    _controllerNote.clear();
                    await callbackRefresh();
                    Toaster().info("Laddu Distributed");
                  } else {
                    Toaster().error("ERROR");
                  }
                }

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<void> returnStock(
    BuildContext context, Future<void> Function() callbackRefresh) async {
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

  if (confirm == true) {
    // await FB().returnLadduStock();

    await callbackRefresh();
  }
}

Widget _getPurposeDropDown(BuildContext context) {
  List<String> Purposes =
      Const().ticketAmounts.map((e) => "Seva ${e.toString()}").toList();

  Purposes.add("Others");
  Purposes.add("Missing");

  return DropdownButtonFormField<String>(
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
