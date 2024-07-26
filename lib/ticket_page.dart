import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/summary.dart';
import 'package:nitya_seva/record.dart';
import 'package:nitya_seva/tally_cash.dart';
import 'package:nitya_seva/tally_upi.dart';

class TicketTable extends StatefulWidget {
  const TicketTable({super.key});

  @override
  State<TicketTable> createState() => _TicketListState();
}

class _TicketListState extends State<TicketTable> {
  List<SevaTicket> sevaTickets = [];
  late DateTime timestampSlot; // timestamp is stored
  String date = '';
  String time = '';

  @override
  void initState() {
    super.initState();

    Record().registerCallbacks(RecordCallbacks(onTicketChange: refresh));

    // Initialize SevaSlot data asynchronously and updates UI with the slot's date, time, and tickets.
    asyncInit().then((value) {
      setState(() {
        var st = Record().sevaTickets[timestampSlot];
        if (st != null) {
          sevaTickets = st;
        }

        date = DateFormat('dd/MM').format(timestampSlot);
        time = DateFormat('HH:mm').format(timestampSlot);
      });
    });
  }

  Future<void> asyncInit() async {
    LS().read('selectedSlot').then((selectedSlot) {
      timestampSlot = DateTime.parse(selectedSlot!);
    }).catchError((error) {
      print('Error fetching selectedSlot: $error');
    });
  }

  Future<void> refresh() async {
    setState(() {
      sevaTickets = Record().sevaTickets[timestampSlot]!;
    });
    print(sevaTickets);
  }

  void onAddEntry(SevaTicket entry) async {
    Record().addSevaTicket(timestampSlot, entry);
  }

  void onEditEntry(SevaTicket entry) async {
    Record().updateSevaTicket(timestampSlot, entry);
  }

  void onDeleteEntry(DateTime timestampTicket) async {
    Record().removeSevaTicket(timestampSlot, timestampTicket);
  }

  int getNextTicket(amount) {
    List<SevaTicket> filteredEntries =
        sevaTickets.where((entry) => entry.amount == amount).toList();

    if (filteredEntries.isEmpty) {
      return 0;
    } else {
      return filteredEntries.map((entry) => entry.ticket).reduce(max) + 1;
    }
  }

  List<PopupMenuButton<String>> _widgetTicketMenu() {
    return [
      PopupMenuButton<String>(
        onSelected: (String result) {
          // Handle menu item selection here
          switch (result) {
            case 'Summary':
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Summary()))
                  .then((_) {
                Record().registerCallbacks(
                    RecordCallbacks(onTicketChange: refresh));
              });
              break;
            case 'Tally cash':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TallyCashPage()));
              break;
            case 'Tally UPI/Card':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TallyUpiPage()));
              break;
            // Add more cases as needed
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Summary',
            child: Row(
              children: <Widget>[
                Icon(Icons.summarize, color: Const().colorPrimary),
                const SizedBox(width: 8),
                const Text('Summary'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Tally cash',
            child: Row(
              children: <Widget>[
                Icon(Icons.money,
                    color: Const().colorPrimary), // Icon for remarks
                const SizedBox(
                    width: 8), // Add some spacing between the icon and the text
                const Text('Tally cash'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'Tally UPI/Card',
            child: Row(
              children: <Widget>[
                Icon(Icons.account_balance_wallet,
                    color: Const().colorPrimary), // Icon for remarks
                const SizedBox(
                    width: 8), // Add some spacing between the icon and the text
                const Text('Tally UPI/Card'),
              ],
            ),
          ),
          // Add more menu items as needed
        ],
      ),
    ];
  }

  PreferredSizeWidget? _widgetAppbar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            date,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (date == DateFormat('dd/MM').format(DateTime.now()))
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Today',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: _widgetTicketMenu(),
    );
  }

  Future<void> _showEntryDialog(
      BuildContext context, SevaTicket? ticket) async {
    // TODO: Function is too big. unable to refactor because of cross dependencies

    // local variables: default values in the dialog
    // when update entry is desired the default values are replaced
    // with the values from passed ticket
    String selectedSevaAmount =
        ticket != null ? ticket.amount.toString() : '400';
    List<String> sevaAmounts = ['400', '500', '1000', '2500'];
    String selectedPaymentMode = ticket != null ? ticket.mode : 'UPI';
    List<String> paymentModes = ['UPI', 'Cash', 'Card'];
    String ticketNumber = ticket != null
        ? ticket.ticket.toString()
        : getNextTicket(int.parse('400')).toString();
    TextEditingController ticketNumberController =
        TextEditingController(text: ticketNumber);

    String user = await LS().read('username') ?? 'Unknown';
    final formKeyTicketNumber =
        GlobalKey<FormState>(); // used for validation of the ticket number

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: ticket != null
              ? const Text('Edit Entry')
              : const Text('New Entry'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // seva amount dropdown
                  DropdownButtonFormField<String>(
                    value: selectedSevaAmount,
                    decoration: const InputDecoration(
                      labelText: 'Seva amount', // Added label
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSevaAmount = newValue!;
                        ticketNumberController.text =
                            getNextTicket(int.parse(selectedSevaAmount))
                                .toString();
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

                  // mode of payment dropdown
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

                  // ticket number text field
                  Form(
                    key: formKeyTicketNumber, // Use the GlobalKey here
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: ticketNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Ticket number',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a ticket number';
                            }
                            final number = int.tryParse(value);
                            if (number == null || number <= 0) {
                              return 'Please enter a valid ticket number';
                            }
                            return null;
                          },
                        ),
                        // Other form fields or widgets
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            if (ticket != null)
              // delete button
              TextButton(
                onPressed: () {
                  // Add your delete logic here
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text(
                            'Are you sure you want to delete this entry?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(), // Dismiss dialog
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              onDeleteEntry(ticket.timestampTicket);
                              Navigator.of(context)
                                  .pop(); // Dismiss dialog after action
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Delete'),
              ),

            // cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),

            // add/update button
            TextButton(
              onPressed: () {
                // validate the ticket number before adding/updating
                if (formKeyTicketNumber.currentState!.validate()) {
                  SevaTicket t = SevaTicket(
                    amount: int.parse(selectedSevaAmount),
                    mode: selectedPaymentMode,
                    ticket: int.tryParse(ticketNumberController.text) ?? 0,
                    user: user,
                    timestampTicket: ticket == null
                        ? DateTime.now()
                        : ticket.timestampTicket,
                    timestampSlot: timestampSlot,
                    remarks: '',
                  );

                  if (ticket == null) {
                    onAddEntry(t);
                  } else {
                    onEditEntry(t);
                  }

                  Navigator.of(context).pop();
                }
              },
              child: ticket != null ? const Text('Update') : const Text('Add'),
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
      Color backgroundShade;

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
          backgroundShade = const Color.fromARGB(255, 1, 169, 247);
          break;
        case 500:
          backgroundColor = Colors.yellow.shade100;
          backgroundShade = const Color.fromARGB(255, 173, 157, 8);
          break;
        case 1000:
          backgroundColor = Colors.lightGreen.shade100;
          backgroundShade = const Color.fromARGB(255, 84, 153, 5);
          break;
        case 2500:
          backgroundColor = Colors.pink.shade100;
          backgroundShade = const Color.fromARGB(255, 249, 3, 89);
          break;
        default:
          backgroundColor = Colors.grey.shade200;
          backgroundShade = const Color.fromARGB(255, 8, 8, 8);
      }

      return ListTile(
        leading: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: backgroundShade,
            shape: BoxShape.circle,
            // border: Border.all(color: Colors.black),
          ),
          child: Center(
            child: Text(
              '${sevaTickets.length - index}',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ticket #: ${entry.ticket}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(DateFormat('HH:mm').format(entry.timestampTicket)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seva karta: ${entry.user}'),
            Text('Amount: ${entry.amount}, Mode: ${entry.mode}'),
          ],
        ),
        trailing: Icon(icon),
        tileColor: backgroundColor,
        onTap: () {
          SevaTicket entry = Record().sevaTickets[timestampSlot]![index];
          _showEntryDialog(context, entry);
        },
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
            const Divider(color: Color.fromARGB(40, 0, 0, 0), height: 1),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEntryDialog(context, null);
        },
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
