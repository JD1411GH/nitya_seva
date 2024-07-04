import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/entry.dart';
import 'package:nitya_seva/slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryTable extends StatefulWidget {
  EntryTable({super.key});

  @override
  State<EntryTable> createState() => _EntryTableState();
}

class _EntryTableState extends State<EntryTable> {
  List<EntryData> listEntries = [];

  void onNewEntry(EntryData entry) async {
    setState(() {
      listEntries.insert(0, entry);
    });

    String slotId = await _fetchSelectedSlot().then((value) => value.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      slotId,
      jsonEncode(listEntries.map((e) => e.toJson()).toList()),
    );
  }

  Future<SlotTile> _fetchSelectedSlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = prefs.getString("selectedSlot");
    return SlotTile.fromJson(jsonDecode(str!));
  }

  Future<Widget> _buildTable() async {
    String slotId = await _fetchSelectedSlot().then((value) => value.id);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = prefs.getString(slotId);
    if (str == null) {
      return const Center(child: Text('No entries found'));
    } else {
      listEntries = (jsonDecode(str) as List)
          .map((e) => EntryData.fromJson(e))
          .toList(); // Convert JSON to List<EntryData>
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
              child:
                  Text("1"), // total tickets sold, not individual amount-wise
            ),
            onTap: () {
              // Define your action upon clicking an item here
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
      ),
      body: FutureBuilder<Widget>(
        future: _buildTable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
                  builder: (context) => EntryWidget(onSave: onNewEntry)));
        },
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
