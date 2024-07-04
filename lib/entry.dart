import 'package:flutter/material.dart';

class EntryData {
  final String time;
  final String author;
  final double amount;
  final String mode;
  final String ticket;

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
  const EntryWidget({super.key});

  @override
  State<EntryWidget> createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Entries'),
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
                    items: [
                      DropdownMenuItem(value: 400, child: Text("400")),
                      DropdownMenuItem(value: 500, child: Text("500")),
                      DropdownMenuItem(value: 1000, child: Text("1000")),
                      DropdownMenuItem(value: 2500, child: Text("2500")),
                    ],
                    onChanged: (value) {
                      // Handle change
                    },
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: DropdownButtonFormField<String>(
                    value: "UPI",
                    items: [
                      DropdownMenuItem(value: "UPI", child: Text("UPI")),
                      DropdownMenuItem(value: "Cash", child: Text("Cash")),
                      DropdownMenuItem(value: "Card", child: Text("Card")),
                    ],
                    onChanged: (value) {
                      // Handle change
                    },
                    decoration: InputDecoration(
                      labelText: 'Payment Mode',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Ticket Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter ticket number';
                      }
                      return null;
                    },
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
                          },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors
                                .green, // Ensures text color contrasts well with the background
                          ),
                        ),
                      ),
                      SizedBox(
                          width:
                              8), // You might want to adjust or remove this based on your layout needs
                      Expanded(
                        // Wrap with Expanded
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle cancel
                          },
                          child: Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors
                                .black, // Changed to a tone of black to match the app theme
                          ),
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
