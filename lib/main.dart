// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/auth.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry_table.dart';
import 'package:nitya_seva/slot.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await loginUser("+918050645849");

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
        context, MaterialPageRoute(builder: (context) => EntryTable()));
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
      drawer: Drawer(),
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
