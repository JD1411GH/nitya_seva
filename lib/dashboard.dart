import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget _widgetDateHeader() {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(now);
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

  Widget _widgetTable(int count) {
    return Table(
      border: TableBorder.all(),
      children: const [
        TableRow(
          children: [
            TableCell(child: Center(child: Text('400'))),
            TableCell(child: Center(child: Text('500'))),
            TableCell(child: Center(child: Text('1000'))),
            TableCell(child: Center(child: Text('2500'))),
            TableCell(child: Center(child: Text('Total'))),
            TableCell(child: Center(child: Text('Amount'))),
          ],
        ),
        // Add more TableRow widgets here as needed
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4.0,
      child: Container(
        width: screenWidth,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _widgetDateHeader(),

            // Morning table
            const SizedBox(height: 20),
            const Text(
              'Morning',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _widgetTable(1),

            // Evening table
            const SizedBox(
                height: 20), // Add some spacing between the date and the table
            const Text(
              'Evening',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _widgetTable(2),

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
}
