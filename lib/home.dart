import 'dart:convert';

import 'package:flutter/material.dart';
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
  List<String> listSelectedSlots = [];

  @override
  void initState() {
    super.initState();
    slotTileList = SlotTileList(SlotTileCallbacks(
        onSlotSelected: onSlotSelected,
        onSlotDeselected: onSlotDeselected,
        onSlotClicked: onSlotClicked));
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

  void onSlotSelected(String id) {
    setState(() {
      listSelectedSlots.add(id);
    });
  }

  void onSlotDeselected(String id) {
    setState(() {
      listSelectedSlots.remove(id);
    });
  }

  Future<void> onSlotClicked(String id) async {
    // store the selected slot
    String selectedSlot = jsonEncode(slotTileList.getSlotTileById(id).toJson());
    await DB().write('selectedSlot', selectedSlot);

    // navigate to the entry table
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const EntryTable()));
  }

  void _addSlotNew() {
    setState(() {
      slotTileList.addSlotTile();
    });
  }

  void _removeSlot() {
    setState(() {
      for (var id in listSelectedSlots) {
        slotTileList.removeSlotTile(id);
      }
      listSelectedSlots.clear();
      slotTileList.clearSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("ISKCON VK Hill Nitya Seva"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: listSelectedSlots.isEmpty ? null : _removeSlot,
          ),
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
