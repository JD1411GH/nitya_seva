import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/datatypes.dart';
import 'package:garuda/fb.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // list of maps, Map<int amount, int count> ticketSummary
  final _lock = Lock();
  List<Map<int, int>> ticketSummary = [];
  DateTime selectedDate = DateTime.now();
  List<String> amountTableHeaderRow = [];
  List<List<int>> amountTableTicketRow =
      []; // [ 400[countTicketMorning, countTicketEvening], 500[countTicketMorning, countTicketEvening] ...]
  List<List<dynamic>> amountTableTotalRow =
      []; // ["Total", countTicketMorning, countTicketEvening], ["Amount", totalAmountMorning, totalAmountEvening]
  List<int> grandTotal = [0, 0]; // [totalTicket, totalAmount]
  Map<String, int> countMode = {
    // {mode: count}
    'UPI': 0,
    'Cash': 0,
    'Card': 0,
  };
  Map<String, int> countModePercentage = {
    // {mode: percentage}
    'UPI': 0,
    'Cash': 0,
    'Card': 0,
  };

  @override
  void initState() {
    super.initState();

    // listen for database changes
    FB().listenForSevaSlotChange(FBCallbacks(onChange: _onSlotChange));
    FB().listenForSevaTicketChange(FBCallbacks(onChange: _onTicketChange));
  }

  destroy() {
    FB().removeSevaSlotListeners();
    FB().removeSevaTicketListeners();
  }

  Future<void> _futureInit() async {
    // reset the selected date to the current date
    // selectedDate = DateTime.now();

    // read from firebase all the slots for the selected date
    // somehow this piece of code was being called from a parallel thread. hence using a mutex.
    await _lock.synchronized(() async {
      amountTableHeaderRow = ['Amount'];
      List<SevaSlot> slots = await FB().readSevaSlotsByDate(selectedDate);
      if (slots.isEmpty) {
        return;
      }
      for (var slot in slots) {
        amountTableHeaderRow.add(slot.title);
      }
    });

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

    // calculate the total count for each slot
    amountTableTotalRow = [
      ["Total"],
      ["Amount"]
    ];
    for (var i = 0; i < amountTableTicketRow.length; i++) {
      // this is the row for table entry, and not the rows for the total

      var row = amountTableTicketRow[i];
      for (var j = 0; j < row.length; j++) {
        var col = row[j];

        // sapecial case for the first column
        if (j == 0) {
          continue;
        }

        // row 0 is count, row 1 is amount

        // fill row 0 first
        // each row is a list by itself
        if (amountTableTotalRow[0].length <= j) {
          // row/col is empty, add the first element
          amountTableTotalRow[0].add(col);
        } else {
          // row is not empty, add the element to the existing element
          amountTableTotalRow[0][j] += col;
        }

        // fill row 1 next
        if (amountTableTotalRow[1].length <= j) {
          // row/col is empty, add the first element
          amountTableTotalRow[1].add(row[0] * col);
        } else {
          // row is not empty, add the element to the existing element
          amountTableTotalRow[1][j] += (row[0] * col);
        }
      }
    }

    // grand total
    grandTotal = [0, 0];
    for (var i = 0; i < amountTableTotalRow.length; i++) {
      for (var j = 0; j < amountTableTotalRow[i].length; j++) {
        if (j == 0) {
          continue;
        }
        grandTotal[i] += (amountTableTotalRow[i][j] as int);
      }
    }

    // pie chart values
    countMode = {
      'UPI': 0,
      'Cash': 0,
      'Card': 0,
    };
    List<SevaSlot> slots = await FB().readSevaSlotsByDate(selectedDate);
    for (var slot in slots) {
      List<SevaTicket>? ticketsFiltered =
          tickets[slot.title]; // tickets for the slot
      if (ticketsFiltered == null) {
        continue;
      }

      for (var ticket in ticketsFiltered) {
        countMode[ticket.mode] = countMode[ticket.mode]! + 1;
      }
    }
    int sum = countMode['UPI']! + countMode['Cash']! + countMode['Card']!;
    if (sum != 0) {
      countModePercentage = {
        'UPI': (countMode['UPI']! / sum * 100).toInt(),
        'Cash': (countMode['Cash']! / sum * 100).toInt(),
        'Card': (countMode['Card']! / sum * 100).toInt(),
      };
    }
  }

  void _onSlotChange(String changeType, dynamic data) {
    Map<String, dynamic> dataMap = (data as Map).cast<String, dynamic>();
    SevaSlot slot = SevaSlot.fromJson(dataMap);

    DateTime slotDate = DateTime(slot.timestampSlot.year,
        slot.timestampSlot.month, slot.timestampSlot.day);
    DateTime selectedDateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (slotDate == selectedDateOnly) {
      setState(() {
        _futureInit();
      });
    }
  }

  void _onTicketChange(String changeType, dynamic data) {
    var dataMap = data as Map;
    for (var entry in dataMap.entries) {
      var json = (entry.value as Map).cast<String, dynamic>();
      SevaTicket ticket = SevaTicket.fromJson(json);

      DateTime slotDate = DateTime(ticket.timestampTicket.year,
          ticket.timestampTicket.month, ticket.timestampTicket.day);
      DateTime selectedDateOnly =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      if (slotDate == selectedDateOnly) {
        setState(() {
          _futureInit();
        });
        break; // Break out of the loop
      }
    }
  }

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
    if (amountTableHeaderRow.length == 1 || grandTotal[0] == 0) {
      return const Text("no data");
    }

    return Table(
      children: [
        TableRow(
          children: amountTableHeaderRow.map((header) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0), // Adjust the padding as needed
              child: Center(
                child: Text(
                  header,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
        ...amountTableTicketRow.map((row) {
          return TableRow(
            children: row.map((cell) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Adjust the padding as needed
                child: Center(
                  child: Text(cell.toString()),
                ),
              );
            }).toList(),
          );
        }),
        ...amountTableTotalRow.map((row) {
          return TableRow(
            children: row.map((cell) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0), // Adjust the padding as needed
                child: Center(
                  child: Text(
                    cell.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }).toList(),
          );
        })
      ],
    );
  }

  Widget _wLegends() {
    if (countModePercentage['UPI'] == 0 &&
        countModePercentage['Cash'] == 0 &&
        countModePercentage['Card'] == 0) {
      return const Text("");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _wLegendItem(Colors.orange, 'UPI'),
        _wLegendItem(Colors.green, 'Cash'),
        _wLegendItem(Colors.blue, 'Card'),
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

  Widget _wPieChart() {
    double radius = 40;

    if (countModePercentage['UPI'] == 0 &&
        countModePercentage['Cash'] == 0 &&
        countModePercentage['Card'] == 0) {
      return const Text("");
    }

    return PieChart(
      PieChartData(
        sections: [
          // UPI
          PieChartSectionData(
            color: Colors.orange,
            value: countModePercentage['UPI']!.toDouble(),
            title: '${countMode['UPI']}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countModePercentage['UPI']! > 9
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            titlePositionPercentageOffset:
                countModePercentage['UPI']! > 9 ? 0.5 : 1.2,
          ),

          // cash
          PieChartSectionData(
            color: Colors.green,
            value: countModePercentage['Cash']!.toDouble(),
            title: '${countMode['Cash']}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countModePercentage['Cash']! > 9
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            titlePositionPercentageOffset:
                countModePercentage['Cash']! > 9 ? 0.5 : 1.2,
          ),

          // card
          PieChartSectionData(
            color: Colors.blue,
            value: countModePercentage['Card']!.toDouble(),
            title: '${countMode['Card']}',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: countModePercentage['Card']! > 9
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyLarge!.color,
            ),
            titlePositionPercentageOffset:
                countModePercentage['Card']! > 9 ? 0.5 : 1.2,
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _futureInit(), // Replace with your actual future
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 400, // Adjust the height as needed
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Loading...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                // User swiped Right
                selectedDate = selectedDate.subtract(const Duration(days: 1));
                setState(() {
                  _futureInit();
                });
              } else if (details.primaryVelocity! < 0) {
                // User swiped Left
                selectedDate = selectedDate.add(const Duration(days: 1));
                setState(() {
                  _futureInit();
                });
              }
            },
            child: Card(
              elevation: 4.0,
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // date header
                        _wDateHeader(),

                        // Pie chart and legends
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100, // Reduced width
                              height: 100, // Reduced height
                              child: _wPieChart(),
                            ),
                            const SizedBox(
                                width: 30), // Increased width for more padding
                            _wLegends(),
                          ],
                        ),

                        // Denomination table
                        const SizedBox(height: 20),
                        _wAmountTable(),

                        // Grand total
                        const SizedBox(height: 20),
                        Text(
                          'Grand Total = ${grandTotal[0]}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Total Amount = Rs. ${grandTotal[1]}',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Use a variant color from the theme
                      ),
                      onPressed: () {
                        setState(() {
                          _futureInit(); // the actual refresh can happen asynchronously
                        });
                      },
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
