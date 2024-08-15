import 'package:flutter/material.dart';

class Dist extends StatefulWidget {
  @override
  _DistState createState() => _DistState();
}

class _DistState extends State<Dist> {
  final primaryColor = Colors.orange;
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: 8.0,
          left: 8.0,
          right: 8.0), // Reduced padding to the top, left, and right
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: primaryColor),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Take only the space needed by children
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isCollapsed = !isCollapsed; // Toggle the collapsed state
                });
              },
              child: Container(
                color: primaryColor, // Dark background for the title
                width: double.infinity, // Fill the entire horizontal space
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Distribution',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
              ),
            ),
            if (!isCollapsed)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Expanded Content'), // Content when expanded
              ),
          ],
        ),
      ),
    );
  }
}
