import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/datatypes.dart';
import 'package:garuda/fb.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // list of maps, Map<int amount, int count> ticketSummary
  List<Map<int, int>> ticketSummary = [];
  DateTime selectedDate = DateTime.now();
  List<String> amountTableHeaderRow = [];
  List<List<int>> amountTableTicketRow =
      []; // [ 400[countTicketMorning, countTicketEvening], 500[countTicketMorning, countTicketEvening] ...]

  Widget _wDateHeader() {
    final String formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);

    return Center(
      child: Text(
        formattedDate,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }

  Widget _wAmountTable() {
    return Table(
      children: [
        TableRow(
          children: amountTableHeaderRow.map((header) {
            return Center(
              child: Text(
                header,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
        ...amountTableTicketRow.map((row) {
          return TableRow(
            children: row.map((cell) {
              return Center(
                child: Text(cell.toString()),
              );
            }).toList(),
          );
        }).toList(),
      ],
    );
  }

  Widget _wLegends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _wLegendItem(Colors.blue, 'Blue - 40%'),
        _wLegendItem(Colors.red, 'Red - 30%'),
        _wLegendItem(Colors.green, 'Green - 30%'),
      ],
    );
  }

  Widget _wLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _wPieMode() {
    double radius = 40;

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 8,
      ),
    );
  }

  List<int> _getRowData(Map<String, List<SevaTicket>> tickets, int amount) {
    List<int> row = [amount];

    for (var slot in amountTableHeaderRow.sublist(1)) {
      List<SevaTicket>? ticketsFiltered = tickets[slot];
      if (ticketsFiltered == null) {
        row.add(0);
      } else {
        List<SevaTicket> ticketsFilteredAmount =
            ticketsFiltered.where((ticket) => ticket.amount == amount).toList();
        row.add(ticketsFilteredAmount.length);
      }
    }

    return row;
  }

  Future<void> _futureInit() async {
    // reset the selected date to the current date
    selectedDate = DateTime.now();

    // read from firebase all the slots for the selected date
    amountTableHeaderRow = ['Amount'];
    List<SevaSlot> slots = await FB().readSevaSlotsByDate(selectedDate);
    for (var slot in slots) {
      amountTableHeaderRow.add(slot.title);
    }

    // count all tickets for the selected date
    amountTableTicketRow = [];
    Map<String, List<SevaTicket>> tickets =
        await FB().readSevaTicketsByDate(selectedDate);
    for (var amount in Const().ticketAmounts) {
      List<int> row = _getRowData(tickets, amount);

      bool rowReplaced = false;
      for (int i = 0; i < amountTableTicketRow.length; i++) {
        if (amountTableTicketRow[i].isNotEmpty &&
            amountTableTicketRow[i][0] == row[0]) {
          amountTableTicketRow[i] = row;
          rowReplaced = true;
          break;
        }
      }
      if (!rowReplaced) {
        amountTableTicketRow.add(row);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _futureInit(), // Replace with your actual future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Card(
            elevation: 4.0,
            child: Container(
              width: screenWidth,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // date header
                  _wDateHeader(),

                  // Pie chart and legends in the same row
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100, // Reduced width
                        height: 100, // Reduced height
                        child: _wPieMode(),
                      ),
                      const SizedBox(width: 10),
                      _wLegends(),
                    ],
                  ),

                  // Denomination table
                  const SizedBox(height: 20),
                  _wAmountTable(),

                  // Grand total
                  const SizedBox(height: 20),
                  Text(
                    'Grand Total = ',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Total Amount = ',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
