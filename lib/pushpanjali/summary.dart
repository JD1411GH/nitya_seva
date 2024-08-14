import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/local_storage.dart';
import 'package:garuda/pushpanjali/record.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/pushpanjali/sevaslot.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  DateTime? timestampSlot;
  final List<List<String>> _items = [];
  List<SevaTicket>? _listEntries;

  void _appendRow(String col1, String col2, {bool bold = false}) {
    _items.last.add("$col1:   $col2");
  }

  void _appendHeadline(String col1, String col2) {
    List<String> amountDetails = ["$col1 $col2"];
    _items.add(amountDetails);
  }

  void _appendSpace() {
    _items.last.add("-");
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
      _appendRow("Amount collected via UPI ", "Rs. ${amountUpi.toString()}");
      _appendRow("Amount collected via Cash ", "Rs. ${amountCash.toString()}");
      _appendRow("Amount collected via Card ", "Rs. ${amountCard.toString()}");

      _appendSpace();
      _appendRow("Total collection",
          "Rs. ${(amountUpi + amountCash + amountCard).toString()}",
          bold: true);
    }

    _appendHeadline("Total", "");
    _appendRow("Total tickets sold", totalTickets.toString(), bold: true);

    _appendSpace();
    _appendRow("Total UPI transactions", totalUpi.toString());
    _appendRow("Total Cash transactions", totalCash.toString());
    _appendRow("Total Card transactions", totalCard.toString());

    _appendSpace();
    _appendRow("Total amount via UPI", "Rs. ${totalUpiAmount.toString()}");
    _appendRow("Total amount via Cash", "Rs. ${totalCashAmount.toString()}");
    _appendRow("Total amount via Card", "Rs. ${totalCardAmount.toString()}");

    _appendSpace();
    _appendRow("Total overall collection", "Rs. ${totalAmount.toString()}",
        bold: true);
  }

  Future<void> _futureInit() async {
    String? str = await LS().read('selectedSlot');

    if (str != null) {
      timestampSlot = DateTime.parse(str);
      _listEntries = Record().sevaTickets[timestampSlot!];
      _populateTable();
    } else {
      Toaster().error("Error reading local storage");
    }
  }

  Color _getColorBasedOnNumber(String header) {
    // Split the string based on whitespace
    List<String> parts = header.split(' ');

    // Get the last part and convert it to an integer
    int number = 0;
    if (header.trim() != 'Total') {
      number = int.parse(parts.last);
    }

    // Select a color based on the number
    switch (number) {
      case 400:
        return Const().color400!;
      case 500:
        return Const().color500!;
      case 1000:
        return Const().color1000!;
      case 2500:
        return Const().color2500!;
      default:
        return const Color.fromARGB(157, 158, 158,
            158); // Default color if the number doesn't match any case
    }
  }

  List<Widget> _getListOfRows(List<String> rows) {
    List<Widget> list = [];
    for (int i = 0; i < rows.skip(1).length; i++) {
      String row = rows.skip(1).elementAt(i);
      if (row == '-') {
        list.add(const Divider()); // Add a divider
      } else {
        list.add(Text(
          row,
          style: TextStyle(
            color: Colors.black, // Text color for the rows
            fontSize: 16.0,
            fontWeight: i == rows.skip(1).length - 1
                ? FontWeight.bold
                : FontWeight.normal, // Make the last item bold
          ),
        ));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Page'),
      ),
      body: FutureBuilder<void>(
        future: _futureInit(), // The future to listen to
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error message if any
          } else {
            return ListView.builder(
              itemCount: _items.length, // Number of _items in the list
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0), // Adjust margin to remove top gap
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for the container
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    border: Border.all(
                      color: Colors.grey, // Border color
                      width: 1.0, // Border width
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the title
                      Container(
                        width: double
                            .infinity, // Make the title container fill the entire width
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: _getColorBasedOnNumber(_items[index]
                              [0]), // Solid background color for the title
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(
                                8.0), // Rounded corners for the top left
                            topRight: Radius.circular(
                                8.0), // Rounded corners for the top right
                          ),
                        ),
                        child: Text(
                          _items[index][0],
                          style: const TextStyle(
                            color: Colors.black, // Text color for the title
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // display the remaining rows
                      const SizedBox(
                          height:
                              8.0), // Add some space between the title and the rows of text
                      Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Add padding inside the tile
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _getListOfRows(_items[index]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ); // Show the fetched data
          }
        },
      ),
    );
  }
}
