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
  Future<SlotTile> _fetchSelectedSlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = prefs.getString("selectedSlot");
    return SlotTile.fromJson(jsonDecode(str!));
  }

  Future<Widget> _buildTable() async {
    String slotId = await _fetchSelectedSlot().then((value) => value.id);

    List<Entry> listEntries = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = prefs.getString(slotId);
    if (str == null) {
      return const Center(child: Text('No entries found'));
    } else {
      listEntries = (jsonDecode(str) as List)
          .map((e) => Entry.fromJson(e))
          .toList(); // Convert JSON to List<Entry>
    }

    return ListView.builder(
      itemCount: listEntries.length,
      itemBuilder: (context, index) {
        final item = listEntries[index];
        return Card(
          margin: EdgeInsets.all(8.0),
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
              // For example, showing a snackbar with the item's author
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Selected author: ${item.author}'),
              ));
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
        onPressed: null,
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
