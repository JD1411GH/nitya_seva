import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nitya_seva/db.dart';
import 'package:nitya_seva/entry.dart';
import 'package:nitya_seva/fb.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/slot.dart';
import 'package:nitya_seva/summary.dart';
import 'package:nitya_seva/toaster.dart';
import 'package:nitya_seva/record.dart';

class EntryTable extends StatefulWidget {
  const EntryTable({super.key});

  @override
  State<EntryTable> createState() => _EntryTableState();
}

class _EntryTableState extends State<EntryTable> {
  List<SevaTicket> sevaTickets = [];
  late String timestampSlot; // timestamp is stored

  @override
  void initState() {
    super.initState();

    asyncInit().then((value) {
      SevaSlot slot = Record().getSevaSlot(timestampSlot);
      setState(() {
        sevaTickets = slot.sevaTickets;
      });
    });
  }

  Future<void> asyncInit() async {
    LS().read('selectedSlot').then((selectedSlot) {
      timestampSlot = selectedSlot!;
    });
  }

  void onAddEntry(SevaTicket entry) async {
    Record().getSevaSlot(timestampSlot).addSevaTicket(entry);
    SevaSlot slot = Record().getSevaSlot(timestampSlot);
    setState(() {
      sevaTickets = slot.sevaTickets;
    });
  }

  void onDeleteEntry(String entryId) async {
    // int index = listEntries.indexWhere((e) => e.entryId == entryId);
    // if (index != -1) {
    //   setState(() {
    //     listEntries.removeAt(index);
    //   });
    // }

    // // serialize count inside listEntries
    // for (int i = listEntries.length - 1; i >= 0; i--) {
    //   setState(() {
    //     listEntries[i].count = listEntries.length - i;
    //   });
    // }

    // String selectedSlotId =
    //     await _fetchSelectedSlot().then((value) => value.id);

    // await DB().writeCloud(
    //   selectedSlotId,
    //   jsonEncode(listEntries.map((e) => e.toJson()).toList()),
    // );

    // Toaster().info("Deleted entry");
  }

  // Future<SlotTile> _fetchSelectedSlot() async {
  //   String? str = await DB().read("selectedSlot");
  //   if (str == null) {
  //     throw Exception('Selected slot is null');
  //   }

  //   return SlotTile.fromJson(jsonDecode(str));
  // }

  // Future<String> _fetchSelectedSlotId() async {
  //   String? str = await DB().read("selectedSlot");
  //   if (str == null) {
  //     throw Exception('Selected slot is null');
  //   }

  //   return SlotTile.fromJson(jsonDecode(str)).id;
  // }

  int getNextTicket(amount) {
    List<EntryData> filteredEntries = [];
    // listEntries.where((entry) => entry.amount == amount).toList();

    if (filteredEntries.isEmpty) {
      return 0;
    } else {
      return filteredEntries.map((entry) => entry.ticket).reduce(max) + 1;
    }
  }

  // Future<Widget> _buildTable() async {
  //   if (listEntries.isEmpty) {
  //     String selectedSlotId = await _fetchSelectedSlotId();
  //     String? str = await DB().readCloud(selectedSlotId);
  //     if (str == null) {
  //       return const Center(child: Text('No entries found'));
  //     } else {
  //       listEntries = (jsonDecode(str) as List)
  //           .map((e) => EntryData.fromJson(e))
  //           .toList(); // Convert JSON to List<EntryData>
  //     }
  //   }

  //   return ListView.builder(
  //     itemCount: listEntries.length,
  //     itemBuilder: (context, index) {
  //       final item = listEntries[index];
  //       return Card(
  //         margin: const EdgeInsets.all(8.0),
  //         child: ListTile(
  //           title: Text(
  //               'Amount: ${item.amount.toStringAsFixed(2)}, Mode: ${item.mode}, Ticket: ${item.ticket}'),
  //           subtitle: Text("Time: ${item.time}, Seva karta: ${item.author}"),
  //           leading: CircleAvatar(
  //             child: Text(item.count
  //                 .toString()), // total tickets sold, not individual amount-wise
  //           ),
  //           onTap: () {
  //             Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                     builder: (context) => EntryWidget(
  //                           data: item,
  //                           callbacks: EntryWidgetCallbacks(
  //                             onSave: onAddEntry,
  //                             onDelete: onDeleteEntry,
  //                             getNextTicket: getNextTicket,
  //                             getCount: () => listEntries.length + 1,
  //                           ),
  //                         )));
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }

  PreferredSizeWidget? _widgetAppbar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: null,
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.summarize),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Summary()));
          },
        ),
      ],
    );
  }

  Future<void> _showEntryDialog(BuildContext context) async {
    String selectedSevaAmount = '400';
    List<String> sevaAmounts = ['400', '500', '1000', '2500'];
    String selectedPaymentMode = 'UPI';
    List<String> paymentModes = ['UPI', 'Cash', 'Card'];
    TextEditingController ticketNumberController =
        TextEditingController(text: getNextTicket(int.parse('400')).toString());

    String user = await LS().read('user') ?? 'Unknown';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Entry'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value: selectedSevaAmount,
                    decoration: const InputDecoration(
                      labelText: 'Seva amount', // Added label
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSevaAmount = newValue!;
                      });
                    },
                    items: sevaAmounts
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedPaymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Mode of payment', // Added label
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPaymentMode = newValue!;
                      });
                    },
                    items: paymentModes
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: ticketNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Ticket number', // Label already exists
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add your add logic here
                SevaTicket ticket = SevaTicket(
                    int.parse(selectedSevaAmount),
                    selectedPaymentMode,
                    int.tryParse(ticketNumberController.text) ?? 0,
                    user);
                onAddEntry(ticket);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _createTilesFromEntries() {
    return List.generate(sevaTickets.length, (index) {
      SevaTicket entry = sevaTickets[index];
      IconData icon;
      Color backgroundColor;

      switch (entry.mode) {
        case 'UPI':
          icon = Icons.account_balance_wallet;
          break;
        case 'Cash':
          icon = Icons.money;
          break;
        case 'Card':
          icon = Icons.credit_card;
          break;
        default:
          icon = Icons.error;
      }

      switch (entry.amount) {
        case 400:
          backgroundColor = Colors.lightBlue.shade100;
          break;
        case 500:
          backgroundColor = Colors.yellow.shade100;
          break;
        case 1000:
          backgroundColor = Colors.lightGreen.shade100;
          break;
        case 2500:
          backgroundColor = Colors.pink.shade100;
          break;
        default:
          backgroundColor = Colors.grey.shade200;
      }

      return ListTile(
        leading: Text('${index + 1}'),
        title: Text('Ticket #: ${entry.ticket}'),
        subtitle: Text('User: ${entry.user}'),
        trailing: Icon(icon),
        tileColor: backgroundColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _widgetAppbar(),
      body: ListView.separated(
        itemCount: _createTilesFromEntries().length,
        itemBuilder: (context, index) => _createTilesFromEntries()[index],
        separatorBuilder: (context, index) =>
            Divider(color: Color.fromARGB(40, 0, 0, 0), height: 1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEntryDialog(context);
        },
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
