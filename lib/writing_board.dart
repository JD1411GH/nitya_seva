import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry.dart';
import 'package:nitya_seva/slot.dart';

class WritingBoard extends StatefulWidget {
  const WritingBoard({super.key});

  @override
  _WritingBoardState createState() => _WritingBoardState();
}

class _WritingBoardState extends State<WritingBoard> {
  List<Text> texts = [];

  @override
  void initState() {
    super.initState();
    _populateBoard();
  }

  void _appendText(String newText) {
    setState(() {
      texts.add(Text(
        newText,
        style: const TextStyle(fontSize: 16),
      ));
    });
  }

  void _appendHeadline(String newText) {
    setState(() {
      texts.add(Text(
        newText,
        style: const TextStyle(fontSize: 24),
      ));
    });
  }

  void _appendSpace() {
    setState(() {
      texts.add(Text("\n\n"));
    });
  }

  Future<void> _populateBoard() async {
    // get the selected slot
    String? str = await DB().read("selectedSlot");
    String slotId = SlotTile.fromJson(jsonDecode(str!)).id;

    // get all entries for selected slot
    List<EntryData> listEntries = [];
    str = await DB().readCloud(slotId);
    if (str == null) {
      print('No entries found');
    } else {
      listEntries = (jsonDecode(str) as List)
          .map((e) => EntryData.fromJson(e))
          .toList(); // Convert JSON to List<EntryData>
    }

    for (int amount in [400, 500, 1000, 2500]) {
      // calculate summary for 400
      List<EntryData> listFiltered =
          listEntries.where((e) => e.amount == amount).toList();

      int entryWithLowestTicket = 0;
      int entryWithHighestTicket = 0;
      if (listFiltered.isNotEmpty) {
        EntryData entry = listFiltered.reduce((currentLowest, next) =>
            next.ticket < currentLowest.ticket ? next : currentLowest);
        entryWithLowestTicket = entry.ticket;

        entry = listFiltered.reduce((currentHighest, next) =>
            next.ticket > currentHighest.ticket ? next : currentHighest);
        entryWithHighestTicket = entry.ticket;
      }

      _appendHeadline("Seva value: $amount");
      _appendText("Starting no: $entryWithLowestTicket");
      _appendText("Ending no: $entryWithHighestTicket");
      int total = entryWithHighestTicket - entryWithLowestTicket + 1;
      _appendText("Total tickets sold: $total");

      int numUpi = listFiltered.where((e) => e.mode == "UPI").length;
      int numCash = listFiltered.where((e) => e.mode == "Cash").length;
      int numCard = listFiltered.where((e) => e.mode == "Card").length;

      int amountUpi = listFiltered
          .where((e) => e.mode == "UPI")
          .fold(0, (previousValue, element) => previousValue + element.amount);
      int amountCash = listFiltered
          .where((e) => e.mode == "Cash")
          .fold(0, (previousValue, element) => previousValue + element.amount);
      int amountCard = listFiltered
          .where((e) => e.mode == "Card")
          .fold(0, (previousValue, element) => previousValue + element.amount);

      _appendText("UPI transactions: $numUpi -> Rs. $amountUpi");
      _appendText("Cash transactions: $numCash -> Rs. $amountCash");
      _appendText("Card transactions: $numCard -> Rs. $amountCard");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: texts,
        ),
      ),
    );
  }
}
