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
  List<String> slotTileTexts = [];
  final Uuid uuid = Uuid();
  String slotId = '';

  void _addSlotTile() {
    String currentDateTime =
        DateFormat('yyyy-MM-dd – kk:mm:ss').format(DateTime.now());
    String userName = "Jayanta Debnath";
    currentDateTime = "$currentDateTime \n$userName";
    setState(() {
      slotTileTexts.insert(0, currentDateTime);
    });
  }

  void onEditSlotTile(id) {
    // Your button action here
    print("edit $id");
  }

  void onDeleteSlotTile(id) {
    // Your button action here
    print("delete $id");
  }

  void onSlotTileSelected(bool selected, String id) {
    if (selected) {
      setState(() {
        if (slotId.isNotEmpty) {
          slotId = '';
        } else {
          slotId = id;
        }
      });
    } else {
      setState(() {
        slotId = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: slotId.isNotEmpty ? () => onEditSlotTile(slotId) : null,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed:
                slotId.isNotEmpty ? () => onDeleteSlotTile(slotId) : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: slotTileTexts.length,
          itemBuilder: (context, index) {
            final String id = uuid.v4(); // Generate a unique ID
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SlotTile(
                id: id,
                buttonText: slotTileTexts[index],
                onSelected: onSlotTileSelected,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addSlotTile,
        tooltip: 'Add slot',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
