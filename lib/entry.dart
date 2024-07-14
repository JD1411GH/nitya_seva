import 'package:flutter/material.dart';
import 'package:nitya_seva/db.dart';
import 'package:uuid/uuid.dart';

class EntryData {
  final String entryId;
  int count; // Changed to non-final to allow modification
  final String time;
  final String author;
  final int amount;
  final String mode;
  final int ticket;

  EntryData({
    required this.entryId,
    required this.count,
    required this.time,
    required this.author,
    required this.amount,
    required this.mode,
    required this.ticket,
  });

  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'count': count,
        'time': time,
        'author': author,
        'amount': amount,
        'mode': mode,
        'ticket': ticket,
      };

  factory EntryData.fromJson(Map<String, dynamic> json) {
    return EntryData(
      entryId: json['entryId'],
      count: json['count'],
      time: json['time'],
      author: json['author'],
      amount: json['amount'],
      mode: json['mode'],
      ticket: json['ticket'],
    );
  }
}

class EntryWidget extends StatefulWidget {
  final EntryData? data;
  const EntryWidget({super.key, this.data});

  @override
  State<EntryWidget> createState() => _EntryWidgetState();
}

class _EntryWidgetState extends State<EntryWidget> {
  int _amount = 400;
  String _mode = "UPI";
  late int? _ticket;
  late TextEditingController _ticketController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.data == null) {
      // _ticket = widget.callbacks.getNextTicket(400);
    } else {
      _ticket = widget.data!.ticket;
    }
    if (_ticket != null) {
      _ticketController = TextEditingController(text: _ticket.toString());
    } else {
      _ticketController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _ticketController.dispose();
    super.dispose();
  }

  void _updateTicket() {
    setState(() {
      // _ticket = widget.callbacks.getNextTicket(_amount);
      if (_ticket != null) {
        _ticketController.text = _ticket.toString();
      } else {
        _ticketController.clear();
      }
    });
  }

  void _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String? username = await DB().read('user');

    EntryData data = EntryData(
      entryId: widget.data == null ? const Uuid().v4() : widget.data!.entryId,
      count: 0,
      // count: widget.data == null
      //     ? widget.callbacks.getCount()
      //     : widget.data!.count,
      time: DateTime.now().toString(),
      author: username!,
      amount: _amount,
      mode: _mode,
      ticket: _ticket!,
    );

    // await widget.callbacks.onSave(data);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: widget.data == null
              ? const Text("New Entry")
              : const Text("Update Entry"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: widget.data != null
                  ? () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                                "Are you sure you want to delete this entry?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // widget.callbacks
                                  //     .onDelete(widget.data!.entryId);
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  : null, // This disables the button when widget.data is null
            ),
          ],
        ),
        body: Padding(
          padding:
              const EdgeInsets.all(16.0), // Adjust the padding value as needed
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: DropdownButtonFormField<int>(
                    value: widget.data == null ? 400 : widget.data!.amount,
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
                        _updateTicket();
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
                    value: widget.data == null ? "UPI" : widget.data!.mode,
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
                    controller: _ticketController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket Number',
                    ),
                    keyboardType:
                        TextInputType.number, // Set the keyboard type to number
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Please enter a valid ticket number';
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

