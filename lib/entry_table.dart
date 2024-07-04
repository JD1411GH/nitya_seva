import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EntryTable extends StatefulWidget {
  EntryTable({super.key});

  SlotTile selectedSlot = SlotTile(id: "unknown id", buttonText: 'unknown slot'); 

  @override
  State<EntryTable> createState() => _EntryTableState();
}

class _EntryTableState extends State<EntryTable> {
  @override
  void initState() {
    _fetchSelectedSlot();
  }

  Future<void> _fetchSelectedSlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? str = await prefs.getString("selectedSlot");

    setState(() {
      widget.selectedSlot = SlotTile.fromJson(jsonDecode(str!));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.selectedSlot.buttonText),
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