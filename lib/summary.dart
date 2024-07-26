import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/record.dart';
import 'package:nitya_seva/tally_cash.dart';
import 'package:nitya_seva/const.dart';
import 'package:nitya_seva/tally_upi_card.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<TableRow> listRows = [];
  String? _selectedSlot;
  List<SevaTicket>? _listEntries;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    LS().read('selectedSlot').then((value) {
      if (value != null) {
        _selectedSlot = value;
        _listEntries = Record().sevaTickets[DateTime.parse(value)];

        if (_validateEntries()) {
          _populateTable();
        }
      }
    });
  }

  void _appendRow(String col1, String col2, {bool bold = false}) {
    setState(() {
      listRows.add(TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0), // Add left padding
            child: Text(col1,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        bold == false ? FontWeight.normal : FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0), // Add left padding
            child: Text(col2,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        bold == false ? FontWeight.normal : FontWeight.bold)),
          ),
        ],
      ));
    });
  }

  void _appendHeadline(String col1, String col2) {
    setState(() {
      listRows.add(TableRow(
        children: [
          Container(
            color: Const().colorPrimary, // Dark background color
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(col1,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors
                          .white)), // Assuming a light text color for contrast
            ),
          ),
          Container(
            color: Const().colorPrimary, // Dark background color
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(col2,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors
                          .white)), // Assuming a light text color for contrast
            ),
          ),
        ],
      ));
    });
  }

  void _appendSpace() {
    setState(() {
      listRows.add(const TableRow(
        children: [
          Text("", style: TextStyle(fontSize: 16)),
          Text("", style: TextStyle(fontSize: 16)),
        ],
      ));
    });
  }

  bool _validateEntries() {
    bool errorOccurred = false;

    // check if no entries are present
    if (_listEntries == null || _listEntries!.isEmpty) {
      errorOccurred = true;
      _appendRow("no entries found", "");
    } else {
      for (int amount in [400, 500, 1000, 2500]) {
        List<SevaTicket> listFiltered =
            _listEntries!.where((e) => e.amount == amount).toList();

        // check if all entries have contiguous ticket numbers
        if (listFiltered.isNotEmpty) {
          List<SevaTicket> sortedList = List.from(listFiltered);
          sortedList.sort((a, b) => a.ticket.compareTo(b.ticket));
          int previousTicket = sortedList[0].ticket;
          for (int i = 1; i < sortedList.length; i++) {
            if (sortedList[i].ticket != previousTicket + 1) {
              errorOccurred = true;
              _appendRow("Ticket numbers not contiguous",
                  "Ticket# ${sortedList[i].ticket}");
              break;
            }
            previousTicket = sortedList[i].ticket;
          }
        }

        // check for duplicate ticket numbers
        List<int> ticketNumbers = listFiltered.map((e) => e.ticket).toList();
        Set<int> ticketSet = ticketNumbers.toSet();

        if (ticketNumbers.length != ticketSet.length) {
          errorOccurred = true;

          // Identify extra tickets
          Map<int, int> ticketCount = {};
          for (int ticket in ticketNumbers) {
            if (ticketCount.containsKey(ticket)) {
              ticketCount[ticket] = ticketCount[ticket]! + 1;
            } else {
              ticketCount[ticket] = 1;
            }
          }

          List<int> extraTickets = ticketCount.entries
              .where((entry) => entry.value > 1)
              .map((entry) => entry.key)
              .toList();

          // Log or handle extra tickets as needed
          for (int extraTicket in extraTickets) {
            _appendRow(
                "Duplicate ticket numbers found", "Ticket# $extraTicket");
          }
        }
      }
    }

    if (errorOccurred) {
      _appendHeadline("ERROR", "");
      return false;
    } else {
      return true;
    }
  }

  Future<void> _populateTable() async {
    // // get the selected slot
    int totalTickets = 0;
    int totalUpi = 0;
    int totalCash = 0;
    int totalCard = 0;
    int totalAmount = 0;
    int totalUpiAmount = 0;
    int totalCashAmount = 0;
    int totalCardAmount = 0;

    for (int amount in [400, 500, 1000, 2500]) {
      List<SevaTicket> listFiltered =
          _listEntries!.where((e) => e.amount == amount).toList();

      // highest and lowest ticket numbers
      int entryWithLowestTicket = 0;
      int entryWithHighestTicket = 0;
      int total = 0;
      if (listFiltered.isNotEmpty) {
        SevaTicket entry = listFiltered.reduce((currentLowest, next) =>
            next.ticket < currentLowest.ticket ? next : currentLowest);
        entryWithLowestTicket = entry.ticket;

        entry = listFiltered.reduce((currentHighest, next) =>
            next.ticket > currentHighest.ticket ? next : currentHighest);
        entryWithHighestTicket = entry.ticket;
      }

      // print
      _appendHeadline("Seva amount", amount.toString());
      _appendRow("Starting no", entryWithLowestTicket.toString());
      _appendRow("Ending no", entryWithHighestTicket.toString());
      if (entryWithHighestTicket != 0) {
        total = entryWithHighestTicket - entryWithLowestTicket + 1;
      }
      _appendRow("Tickets sold", total.toString());

      // count of transactions per mode
      int numUpi = listFiltered.where((e) => e.mode == "UPI").length;
      int numCash = listFiltered.where((e) => e.mode == "Cash").length;
      int numCard = listFiltered.where((e) => e.mode == "Card").length;
      totalTickets = totalTickets + numUpi + numCash + numCard;
      totalUpi = totalUpi + numUpi;
      totalCash = totalCash + numCash;
      totalCard = totalCard + numCard;

      // amount per mode
      int amountUpi = listFiltered
          .where((e) => e.mode == "UPI")
          .fold(0, (previousValue, element) => previousValue + element.amount);
      int amountCash = listFiltered
          .where((e) => e.mode == "Cash")
          .fold(0, (previousValue, element) => previousValue + element.amount);
      int amountCard = listFiltered
          .where((e) => e.mode == "Card")
          .fold(0, (previousValue, element) => previousValue + element.amount);
      totalAmount = totalAmount + amountUpi + amountCash + amountCard;
      totalUpiAmount = totalUpiAmount + amountUpi;
      totalCashAmount = totalCashAmount + amountCash;
      totalCardAmount = totalCardAmount + amountCard;

      _appendSpace();
      _appendRow("No. of UPI transactions", numUpi.toString());
      _appendRow("No. of Cash transactions", numCash.toString());
      _appendRow("No. of Card transactions", numCard.toString());

      _appendSpace();
      _appendRow("Amount collected via UPI ", amountUpi.toString());
      _appendRow("Amount collected via Cash ", amountCash.toString());
      _appendRow("Amount collected via Card ", amountCard.toString());
      _appendRow(
          "Total collection", (amountUpi + amountCash + amountCard).toString(),
          bold: true);

      _appendSpace();
    }

    _appendHeadline("Total", "");
    _appendRow("Total tickets sold", totalTickets.toString(), bold: true);

    _appendSpace();
    _appendRow("Total UPI transactions", totalUpi.toString());
    _appendRow("Total Cash transactions", totalCash.toString());
    _appendRow("Total Card transactions", totalCard.toString());

    _appendSpace();
    _appendRow("Total amount via UPI", totalUpiAmount.toString());
    _appendRow("Total amount via Cash", totalCashAmount.toString());
    _appendRow("Total amount via Card", totalCardAmount.toString());

    _appendSpace();
    _appendRow("Total overall collection", totalAmount.toString(), bold: true);

    _appendSpace();
    _appendSpace();
    _appendSpace();
    _appendSpace();
    _appendSpace();
  }

  Widget _widgetTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(),
        1: FlexColumnWidth(),
      },
      border: TableBorder.all(
        color: const Color.fromARGB(
            255, 205, 203, 203), // Use a very light grey color
        width: 0.5, // Make the border thin
      ),
      children: listRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: _widgetTable(),
      ),
    );
  }
}
