import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Entries extends StatefulWidget {
  Entries({super.key});

  SlotTile selectedSlot = SlotTile(id: "unknown id", buttonText: 'unknown slot'); 

  @override
  State<Entries> createState() => _EntriesState();
}

class _EntriesState extends State<Entries> {
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
        child: Text('Entries'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}