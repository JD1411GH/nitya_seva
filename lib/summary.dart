import 'package:flutter/material.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/record.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  List<TableRow> listRows = [];

  @override
  void initState() {
    super.initState();
    _populateTable();
  }

  void _appendRow(String col1, String col2) {
    setState(() {
      listRows.add(TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0), // Add left padding
            child: Text(col1, style: const TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0), // Add left padding
            child: Text(col2, style: const TextStyle(fontSize: 16)),
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
            color:
                const Color.fromARGB(255, 163, 98, 32), // Dark background color
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
            color:
                const Color.fromARGB(255, 163, 98, 32), // Dark background color
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

  Future<void> _populateTable() async {
    // // get the selected slot
    String selectedSlot = await LS().read('selectedSlot') ?? "";
    int totalTickets = 0;
    int totalUpi = 0;
    int totalCash = 0;
    int totalCard = 0;
    int totalAmount = 0;
    int totalUpiAmount = 0;
    int totalCashAmount = 0;
    int totalCardAmount = 0;

    // // get all entries for selected slot
    List<SevaTicket> listEntries =
        Record().sevaTickets[DateTime.parse(selectedSlot)] ?? [];

    for (int amount in [400, 500, 1000, 2500]) {
      List<SevaTicket> listFiltered =
          listEntries.where((e) => e.amount == amount).toList();

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

      _appendRow("UPI transactions", "count: $numUpi \nRs. $amountUpi");
      _appendRow("Cash transactions", "count: $numCash \nRs. $amountCash");
      _appendRow("Card transactions", "count: $numCard \nRs. $amountCard");

      _appendSpace();
    }

    _appendHeadline("Total", "");
    _appendRow("Total tickets sold", totalTickets.toString());
    _appendRow("Total UPI transactions", totalUpi.toString());
    _appendRow("Total Cash transactions", totalCash.toString());
    _appendRow("Total Card transactions", totalCard.toString());
    _appendRow("Total amount received", totalAmount.toString());
    _appendRow("Total amount through UPI", totalUpiAmount.toString());
    _appendRow("Total amount through Cash", totalCashAmount.toString());
    _appendRow("Total amount through Card", totalCardAmount.toString());
    _appendSpace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Table(
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
        ),
      ),
    );
  }
}
