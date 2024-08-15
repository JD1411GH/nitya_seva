import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  bool isCollapsed = true;

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
          border: Border.all(color: Colors.black),
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
                color: Colors.black, // Dark background for the title
                width: double.infinity, // Fill the entire horizontal space
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Title',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
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
