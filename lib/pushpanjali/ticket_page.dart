import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:garuda/const.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/pushpanjali/summary.dart';
import 'package:garuda/pushpanjali/record.dart';
import 'package:garuda/pushpanjali/tally_cash.dart';
import 'package:garuda/pushpanjali/tally_upi_card.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';

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
  }

  Future<void> _refreshFull() async {
    await Record().refreshSevaTickets(timestampSlot);
    refresh();
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
                      builder: (context) => const TallyUpiCardPage()));
              break;
            // Add more cases as needed
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'Summary',
            child: Row(
              children: <Widget>[
                Icon(Icons.summarize, color: Theme.of(context).iconTheme.color),
                const SizedBox(width: 8),
                Text('Summary', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'Tally cash',
            child: Row(
              children: <Widget>[
                Icon(Icons.money,
                    color:
                        Theme.of(context).iconTheme.color), // Icon for remarks
                const SizedBox(
                    width: 8), // Add some spacing between the icon and the text
                Text('Tally cash',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),

          PopupMenuItem<String>(
            value: 'Tally UPI/Card',
            child: Row(
              children: <Widget>[
                Icon(Icons.account_balance_wallet,
                    color:
                        Theme.of(context).iconTheme.color), // Icon for remarks
                const SizedBox(
                    width: 8), // Add some spacing between the icon and the text
                Text('Tally UPI/Card',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          // Add more menu items as needed
        ],
      ),
    ];
  }

  PreferredSizeWidget? _widgetAppbar() {
    String title = 'Seva tickets';
    // ignore: unused_local_variable
    SevaSlot? sevaSlot = Record().sevaSlots.firstWhere(
          (slot) => slot.timestampSlot == timestampSlot,
        );
    title = sevaSlot.title;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 18), // Reduced font size for the title
          ),
          Text(
            sevaSlot.sevakartaSlot, // Seva karta name
            style: const TextStyle(
                fontSize: 14), // Smaller font size than the title
          ),
        ],
      ),
      actions: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('dd/MM')
                  .format(timestampSlot), // Date in "DD/MM" format
              style: Theme.of(context)
                  .textTheme
                  .titleSmall, // Smaller font size than the title
            ),
            Text(
              DateFormat('HH:mm')
                  .format(timestampSlot), // Time in "HH:MM" format
              style: Theme.of(context)
                  .textTheme
                  .titleSmall, // Smaller font size than the title
            ),
          ],
        ),

        // action menu
        ..._widgetTicketMenu(),
      ],
    );
  }

  Future<void> _showEntryDialog(
      BuildContext context, SevaTicket? ticket) async {
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
      Color backgroundColor;
      Color backgroundShade;
      String iconPath = 'assets/images/Garuda.jpg'; // Default icon path

      switch (entry.mode) {
        case 'UPI':
          iconPath =
              'assets/images/icon_upi.png'; // Replace with your image path
          break;
        case 'Cash':
          iconPath =
              'assets/images/icon_cash.png'; // Replace with your image path
          break;
        case 'Card':
          iconPath =
              'assets/images/icon_card.png'; // Replace with your image path
          break;
        default:
          iconPath = 'assets/images/Garuda.jpg';
      }

      switch (entry.amount) {
        case 400:
          backgroundColor = Const().color400!;
          backgroundShade = Const().color400variant!;
          break;
        case 500:
          backgroundColor = Const().color500!;
          backgroundShade = Const().color500variant!;
          break;
        case 1000:
          backgroundColor = Const().color1000!;
          backgroundShade = Const().color1000variant!;
          break;
        case 2500:
          backgroundColor = Const().color2500!;
          backgroundShade = Const().color2500variant!;
          break;
        default:
          backgroundColor = Theme.of(context).colorScheme.primary;
          backgroundShade = Theme.of(context).colorScheme.primaryContainer;
      }

      return Stack(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.only(
                top: 32.0), // Add padding to make space for the title band

            // count of tickets
            leading: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: 8.0), // Adjust the padding values as needed
              child: CircleAvatar(
                backgroundColor: backgroundShade, // Light background color
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: backgroundShade,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${sevaTickets.length - index}',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),

            // Other details
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.user),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            subtitle: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                  'Time: ${DateFormat('HH:mm').format(entry.timestampTicket)}, Mode: ${entry.mode}'),
            ),

            // mode of payment icon
            trailing: Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
              ), // Adjust the padding values as needed
              child: Column(
                children: [
                  Flexible(
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit
                          .contain, // Ensures the image shrinks to fit the parent container
                    ),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ), // Add some spacing between the icon and the text
                ],
              ),
            ), // Trailing icon: mode of payment

            onTap: () {
              SevaTicket entry = Record().sevaTickets[timestampSlot]![index];
              _showEntryDialog(context, entry);
            },
          ),

          // title band
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor, // Dark background color
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0), // Rounded top-left corner
                  topRight: Radius.circular(8.0), // Rounded top-right corner
                ),
              ),
              padding:
                  const EdgeInsets.all(8.0), // Padding inside the title band
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ticket number
                  Text(
                    'Ticket #: ${entry.ticket}',
                    style: const TextStyle(
                      color: Colors.black, // Light text color
                      fontWeight: FontWeight.bold,
                      fontSize: 18, // Adjust font size as needed
                    ),
                  ),

                  // amount
                  Text(
                    "Rs. ${entry.amount}",
                    style: const TextStyle(
                      color: Colors.black, // Light text color
                      fontSize: 16, // Adjust font size as needed
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<List<Widget>> _futureInit() async {
    var selectedSlot = await LS().read('selectedSlot');
    timestampSlot = DateTime.parse(selectedSlot!);

    return _createTilesFromEntries();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        } else {
          return Scaffold(
            appBar: _widgetAppbar(),
            body: RefreshIndicator(
              onRefresh: _refreshFull,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal:
                                  8.0), // Optional: Add some margin around the box
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.grey), // Border color
                            borderRadius: BorderRadius.circular(
                                8.0), // Optional: Add rounded corners
                          ),
                          child: snapshot.data![index],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _showEntryDialog(context, null);
              },
              tooltip: 'Add new entry',
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          );
        }
      },
    );
  }
}
