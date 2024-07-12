import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry.dart';
import 'package:nitya_seva/slot.dart';
import 'package:nitya_seva/summary.dart';

class EntryTable extends StatefulWidget {
  const EntryTable({super.key});

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
            subtitle: Text("Time: ${item.time}, Author: ${item.author}"),
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
