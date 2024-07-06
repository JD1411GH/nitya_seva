import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry.dart';
import 'package:nitya_seva/slot.dart';

class SummaryWidget extends StatelessWidget {
  Future<List<SummaryData>> fetchData() async {
    // get the selected slot
    String? str = await DB().read("selectedSlot");
    if (str == null) {
      throw Exception('Selected slot is null');
    }
    String slotId = SlotTile.fromJson(jsonDecode(str)).id;

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

    List<SummaryData> listSummary = [];

    for (int amount in [400, 500, 1000, 2500]) {
      // calculate summary for 400
      List<EntryData> filter =
          listEntries.where((e) => e.amount == amount).toList();
      EntryData entryWithLowestTicket = filter.reduce((currentLowest, next) =>
          next.ticket < currentLowest.ticket ? next : currentLowest);
      EntryData entryWithHighestTicket = filter.reduce((currentHighest, next) =>
          next.ticket > currentHighest.ticket ? next : currentHighest);

      SummaryData summary = SummaryData(
        amount: amount,
        start: entryWithLowestTicket.ticket,
        end: entryWithHighestTicket.ticket,
        numUpi: filter.where((e) => e.mode == "UPI").length,
        numCash: filter.where((e) => e.mode == "Cash").length,
        numCard: filter.where((e) => e.mode == "Card").length,
        amountUpi: filter.where((e) => e.mode == "UPI").fold(
            0, (previousValue, element) => previousValue + element.amount),
        amountCash: filter.where((e) => e.mode == "Cash").fold(
            0, (previousValue, element) => previousValue + element.amount),
        amountCard: filter.where((e) => e.mode == "Card").fold(
            0, (previousValue, element) => previousValue + element.amount),
      );

      listSummary.add(summary);
    }

    return listSummary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Summary'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: FutureBuilder<List<SummaryData>>(
          future: fetchData(), // Your async data fetching function
          builder: (BuildContext context,
              AsyncSnapshot<List<SummaryData>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator while waiting for data
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error if something went wrong
            } else {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seva ticket details',
                    style: TextStyle(
                      fontSize: 24.0, // Headline font size
                      fontWeight: FontWeight.bold, // Makes the font bold
                      // fontFamily: 'YourFontFamily', // Optional: Specify your font family
                    ),
                  ),
                  SizedBox(height: 8), // Space between texts
                  Text(
                    "", // Use the data from the future
                    style: TextStyle(
                      fontSize: 16.0, // Regular text font size
                      fontWeight: FontWeight.normal, // Regular font weight
                      // fontFamily: 'YourFontFamily', // Optional: Specify your font family
                    ),
                  ),
                ],
              );
            }
          },
        ));
  }
}

class SummaryData {
  final int amount;
  final int start;
  final int end;
  final int numUpi;
  final int numCash;
  final int numCard;
  final int amountUpi;
  final int amountCash;
  final int amountCard;

  SummaryData(
      {required this.amount,
      required this.start,
      required this.end,
      required this.numUpi,
      required this.numCash,
      required this.numCard,
      required this.amountUpi,
      required this.amountCash,
      required this.amountCard});
}
