import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:garuda/admin/user.dart';
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
                  Toaster().info("Added successfully");
                  await callbackRefresh();
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

void showDialogFailedValidation(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Validation failed',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
