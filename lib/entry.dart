import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryData {
  final String time;
  final String author;
  final int amount;
  final String mode;
  final int ticket;

  EntryData({
    required this.time,
    required this.author,
    required this.amount,
    required this.mode,
    required this.ticket,
  });

  Map<String, dynamic> toJson() => {
        'time': time,
        'author': author,
        'amount': amount,
        'mode': mode,
        'ticket': ticket,
      };

  factory EntryData.fromJson(Map<String, dynamic> json) {
    return EntryData(
      time: json['time'],
      author: json['author'],
      amount: json['amount'],
      mode: json['mode'],
      ticket: json['ticket'],
    );
  }
}

class EntryWidget extends StatefulWidget {
  final Function(EntryData) onSave;
  const EntryWidget({super.key, required this.onSave});

  @override
  State<EntryWidget> createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {
  int _amount = 400;
  String _mode = "UPI";
  int _ticket = 0;

  void _onSave() async {
    widget.onSave(EntryData(
      time: DateTime.now().toString(),
      author: "Jayanta Debnath",
      amount: _amount,
      mode: _mode,
      ticket: _ticket,
    ));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Entry'),
        ),
        body: Padding(
          padding:
              const EdgeInsets.all(16.0), // Adjust the padding value as needed
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: DropdownButtonFormField<int>(
                    value: 400,
                    items: const [
                      DropdownMenuItem(value: 400, child: Text("400")),
                      DropdownMenuItem(value: 500, child: Text("500")),
                      DropdownMenuItem(value: 1000, child: Text("1000")),
                      DropdownMenuItem(value: 2500, child: Text("2500")),
                    ],
                    onChanged: (value) {
                      // Handle change
                      if (value != null) {
                        _amount = value;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: DropdownButtonFormField<String>(
                    value: "UPI",
                    items: const [
                      DropdownMenuItem(value: "UPI", child: Text("UPI")),
                      DropdownMenuItem(value: "Cash", child: Text("Cash")),
                      DropdownMenuItem(value: "Card", child: Text("Card")),
                    ],
                    onChanged: (value) {
                      // Handle change
                      if (value != null) {
                        _mode = value;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Mode',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Ticket Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ticket number';
                      }
                      return null;
                    },
                    onChanged: (value) => _ticket = int.parse(value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      0, 32.0, 0, 16.0), // Increased padding for vertical only
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Align buttons to horizontal center
                    children: <Widget>[
                      Expanded(
                        // Wrap with Expanded
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle save
                            _onSave();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors
                                .green, // Ensures text color contrasts well with the background
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                      const SizedBox(
                          width:
                              8), // You might want to adjust or remove this based on your layout needs
                      Expanded(
                        // Wrap with Expanded
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(
                                context); // Close the screen (dismiss the widget
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors
                                .black, // Changed to a tone of black to match the app theme
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
} // class _EntryWidgetState
