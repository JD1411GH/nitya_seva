import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry.dart';
import 'package:nitya_seva/slot.dart';
import 'package:nitya_seva/summary.dart';

class EntryTable extends StatefulWidget {
  final EntryTableCallbacks callbacks;
  const EntryTable({super.key, required this.callbacks});

  @override
  State<EntryTable> createState() => _EntryTableState();
}

class _EntryTableState extends State<EntryTable> {
  List<EntryData> listEntries = [];

  @override
  void initState() {
    super.initState();
  }

  void onSaveEntry(EntryData entry) async {
    int index = listEntries.indexWhere((e) => e.entryId == entry.entryId);
    if (index != -1) {
      // Replace the existing entry with the new one
      setState(() {
        listEntries[index] = entry;
      });
    } else {
      // Insert the new entry at the beginning of the list
      setState(() {
        listEntries.insert(0, entry);
      });
    }

    String selectedSlotId =
        await _fetchSelectedSlot().then((value) => value.id);
    DB().writeCloud(
      selectedSlotId,
      jsonEncode(listEntries.map((e) => e.toJson()).toList()),
    );
  }

  void onDeleteEntry(String entryId) async {
    int index = listEntries.indexWhere((e) => e.entryId == entryId);
    if (index != -1) {
      setState(() {
        listEntries.removeAt(index);
      });
    }

    // serialize count inside listEntries
    for (int i = listEntries.length - 1; i >= 0; i--) {
      setState(() {
        listEntries[i].count = listEntries.length - i;
      });
    }

    String selectedSlotId =
        await _fetchSelectedSlot().then((value) => value.id);

    DB().writeCloud(
      selectedSlotId,
      jsonEncode(listEntries.map((e) => e.toJson()).toList()),
    );
  }

  Future<SlotTile> _fetchSelectedSlot() async {
    String? str = await DB().read("selectedSlot");
    if (str == null) {
      throw Exception('Selected slot is null');
    }

    return SlotTile.fromJson(jsonDecode(str));
  }

  Future<String> _fetchSelectedSlotId() async {
    String? str = await DB().read("selectedSlot");
    if (str == null) {
      throw Exception('Selected slot is null');
    }

    return SlotTile.fromJson(jsonDecode(str)).id;
  }

  int? getNextTicket(amount) {
    List<EntryData> filteredEntries =
        listEntries.where((entry) => entry.amount == amount).toList();

    if (filteredEntries.isEmpty) {
      return null;
    } else {
      return filteredEntries.map((entry) => entry.ticket).reduce(max) + 1;
    }
  }

  Future<Widget> _buildTable() async {
    if (listEntries.isEmpty) {
      String selectedSlotId = await _fetchSelectedSlotId();
      String? str = await DB().readCloud(selectedSlotId);
      if (str == null) {
        return const Center(child: Text('No entries found'));
      } else {
        listEntries = (jsonDecode(str) as List)
            .map((e) => EntryData.fromJson(e))
            .toList(); // Convert JSON to List<EntryData>
      }
    }

    return ListView.builder(
      itemCount: listEntries.length,
      itemBuilder: (context, index) {
        final item = listEntries[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(
                'Amount: ${item.amount.toStringAsFixed(2)}, Mode: ${item.mode}, Ticket: ${item.ticket}'),
            subtitle: Text("Time: ${item.time}, Seva karta: ${item.author}"),
            leading: CircleAvatar(
              child: Text(item.count
                  .toString()), // total tickets sold, not individual amount-wise
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EntryWidget(
                            data: item,
                            callbacks: EntryWidgetCallbacks(
                              onSave: onSaveEntry,
                              onDelete: onDeleteEntry,
                              getNextTicket: getNextTicket,
                              getCount: () => listEntries.length + 1,
                            ),
                          )));
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: FutureBuilder<SlotTile>(
          future: _fetchSelectedSlot(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(
                snapshot.data!.buttonText,
                style: Theme.of(context).textTheme.bodyMedium,
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Summary()));
            },
          ),
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Delete"),
                      content: const Text(
                          "Are you sure you want to delete this page?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () async {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop(); // Close the dialog
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();

                            String id = await _fetchSelectedSlotId();
                            widget.callbacks.onSlotDelete(id);
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    );
                  },
                );
              } //onPressed
              ), // IconButton
          // onPressed: () async {
          //   String id = await _fetchSelectedSlotId();
          //   widget.callbacks.onSlotDelete(id);
          //   // ignore: use_build_context_synchronously
          //   Navigator.pop(context);
          // }
        ],
      ),
      body: FutureBuilder<Widget>(
        future: _buildTable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == null) {
              return const Center(child: Text('No entries found'));
            }
            return snapshot.data!;
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EntryWidget(
                        callbacks: EntryWidgetCallbacks(
                          onSave: onSaveEntry,
                          onDelete: onDeleteEntry,
                          getNextTicket: getNextTicket,
                          getCount: () => listEntries.length + 1,
                        ),
                      )));
        },
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EntryTableCallbacks {
  final Function(String SlotId) onSlotDelete;

  EntryTableCallbacks({
    required this.onSlotDelete,
  });
}
