import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
import 'package:garuda/const.dart';
import 'package:garuda/fb.dart';
import 'package:garuda/laddu_seva/datatypes.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/toaster.dart';

Future<void> addStock(
    BuildContext context, Future<void> Function() callbackRefresh) async {
  String from = "";
  int procured = 0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Add Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // text input for collected from
            TextField(
              decoration: InputDecoration(labelText: 'From'),
              onChanged: (value) {},
            ),

            // text input for packs procured
            TextField(
              decoration: InputDecoration(labelText: 'Packs procured'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                procured = int.parse(value);
              },
            ),
          ],
        ),
        actions: [
          // cancel button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),

          // add stock button
          ElevatedButton(
            onPressed: () async {
              var u = await LS().read('user_details');
              if (u != null) {
                var uu = jsonDecode(u);
                UserDetails user = UserDetails.fromJson(uu);

                LadduStock stock = LadduStock(
                  timestamp: DateTime.now(),
                  user: user.name!,
                  from: from,
                  count: procured,
                );

                bool status = await FB().addLadduStock(stock);
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
            child: Text('Add'),
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
      String selectedPurpose = "Others";
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
              _getPurposeDropDown(context, selectedPurpose),

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

                  bool status = await FB().addLadduDist(dist);
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

Widget _getPurposeDropDown(BuildContext context, String selectedPurpose) {
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
