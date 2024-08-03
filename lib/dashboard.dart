import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:garuda/datatypes.dart';
import 'package:garuda/fb.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // list of maps, Map<int deno, int count> ticketSummary
  List<Map<int, int>> ticketSummary = [];
  DateTime selectedDate = DateTime.now();

  Widget _wDateHeader() {
    final String formattedDate =
        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);

    return Center(
      child: Text(
        formattedDate,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _wDenoTable() {
    // Sample data for the table
    final data = [
      [1, 10, 20],
      [2, 15, 25],
      [3, 20, 30],
      [4, 25, 35],
    ];

    return Table(
      children: [
        const TableRow(
          children: [
            Center(
                child: Text('denomination',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child: Text('morning',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            Center(
                child: Text('evening',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        ...data.map((row) {
          return TableRow(
            children: row
                .map((cell) => Center(child: Text(cell.toString())))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _wPieMode() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: 40,
            title: '40%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 0,
      ),
    );
  }

  Future<void> _futureInit() async {
    // do not call SetState here

    selectedDate = DateTime.now();

    List<SevaTicket> sevatickets =
        await FB().readSevaTicketsByDate(selectedDate);

    print(sevatickets);
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

                  // Morning table and pie chart
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _wDenoTable(),
                      ),
                      SizedBox(
                        width: 100, // Adjust the width as necessary
                        height: 100, // Adjust the height as necessary
                        child: _wPieMode(),
                      ),
                    ],
                  ),

                  // Grand total
                  const SizedBox(height: 20),
                  const Text(
                    'Grand Total = ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Total Amount = ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
