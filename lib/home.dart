import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/login.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry_table.dart';
import 'package:nitya_seva/logout.dart';
import 'package:nitya_seva/slot.dart';
import 'package:nitya_seva/toaster.dart';
import 'package:nitya_seva/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SevaSlot> sevaSlots = Record().sevaSlots;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addNewSlot() async {
    String? user = await LS().read('user');
    SevaSlot slot = SevaSlot(user!);
    Record().addSevaSlot(slot);

    // refresh homepage
    setState(() {
      sevaSlots = Record().sevaSlots;
    });
  }

  Widget _itemBuilderSlots(context, index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest, // Border color
          width: 1.0, // Border width
        ),
        borderRadius: BorderRadius.circular(4.0), // Border radius
      ),
      margin: const EdgeInsets.symmetric(
          vertical: 4.0, horizontal: 8.0), // Margin around the container
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(sevaSlots[index]
                        .timestamp), // Extract and format the date
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    DateFormat('HH:mm:ss').format(sevaSlots[index]
                        .timestamp), // Extract and format the time
                    textAlign: TextAlign.right, // Align the time to the right
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6)),
                  ),
                ),
              ],
            ),
            Text(sevaSlots[index].sevakarta), // Display sevakarta
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Const().appName),
        actions: const <Widget>[
          LogoutButton(),
        ],
      ),
      drawer: const Drawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: sevaSlots.length,
          itemBuilder: _itemBuilderSlots,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSlot,
        tooltip: 'Add slot',
        child: const Icon(Icons.create_new_folder),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
