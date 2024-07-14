import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/login.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry_table.dart';
import 'package:nitya_seva/logout.dart';
import 'package:nitya_seva/slot.dart';
import 'package:nitya_seva/toaster.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _addNewSlot() async {
    print(await LS().read("user"));
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
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSlot,
        tooltip: 'Add slot',
        child: const Icon(Icons.create_new_folder),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
