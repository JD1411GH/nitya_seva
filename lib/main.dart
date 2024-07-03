// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:nitya_seva_calculation/slot_tile.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const NityaSevaApp());
}

class NityaSevaApp extends StatelessWidget {
  const NityaSevaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 222, 150, 67)),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'VK Hill Nitya Seva'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

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
        onSlotSelected: onSlotSelected, onSlotDeselected: onSlotDeselected));
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
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: listSelectedSlots.isEmpty ? null : _removeSlot,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: slotTileList.listSlotTiles
              .map((widget) =>
                  Padding(padding: EdgeInsets.all(8.0), child: widget))
              .toList(),
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
