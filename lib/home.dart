import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/auth.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry_table.dart';
import 'package:nitya_seva/slot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SlotTileList slotTileList;

  @override
  void initState() {
    super.initState();
    slotTileList =
        SlotTileList(SlotTileCallbacks(onSlotClicked: onSlotClicked));
    _initListSlotTiles();
  }

  Future<void> _initListSlotTiles() async {
    await slotTileList.initListSlotTiles(); // Load data from SharedPreferences
    setState(() {
      // This call to setState will trigger a rebuild once the data is loaded.
      // You don't need to do anything here if slotTileList.initListSlotTiles() already updates the list.
      // The purpose of calling setState() is just to ensure the widget rebuilds.
    });
  }

  Future<void> onSlotClicked(String id) async {
    // store the selected slot
    String selectedSlot = jsonEncode(slotTileList.getSlotTileById(id).toJson());
    await DB().write('selectedSlot', selectedSlot);

    // navigate to the entry table
    Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(
            builder: (context) => EntryTable(
                callbacks: EntryTableCallbacks(onSlotDelete: _removeSlot))));
  }

  void _addSlotNew() {
    setState(() {
      slotTileList.addSlotTile();
    });
  }

  void _removeSlot(String slotId) {
    setState(() {
      slotTileList.removeSlotTile(slotId); // this care of writing to database
      slotTileList.clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Nitya Seva - ISKCON VK Hills"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                DB().delete('user');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              }),
        ],
      ),
      drawer: const Drawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          // Wrap the Column in a SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: slotTileList.listSlotTiles
                .map((widget) =>
                    Padding(padding: const EdgeInsets.all(8.0), child: widget))
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlotNew,
        tooltip: 'Add slot',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
