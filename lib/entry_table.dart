import 'dart:convert';

import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: FutureBuilder<SlotTile>(
          future: _fetchSelectedSlot(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(snapshot.data!.buttonText);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: null,
          ),
        ],
      ),
      body: Center(
        child: Text('EntryTable'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}