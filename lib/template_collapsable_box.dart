import 'package:flutter/material.dart';
import 'package:garuda/const.dart';
import 'package:garuda/utils.dart';

class Dist extends StatefulWidget {
  @override
  _DistState createState() => _DistState();
}

final GlobalKey<_DistState> DistKey = GlobalKey<_DistState>();

class _DistState extends State<Dist> {
  final primaryColorDefault = Utils().getRandomDarkColor();
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
          border: Border.all(color: primaryColorDefault),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Take only the space needed by children
          children: [
            // title bar
            GestureDetector(
              onTap: () {
                setState(() {
                  isCollapsed = !isCollapsed; // Toggle the collapsed state
                });
              },
              child: Container(
                color: primaryColorDefault, // Dark background for the title
                width: double.infinity, // Fill the entire horizontal space
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Title',
                  style: TextStyle(
                    color: Colors.white, // Set the text color to white
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold, // Make the text bold
                  ),
                ),
              ),
            ),

            // body
            if (!isCollapsed)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Expanded Content'), // Content when expanded
                    Text('Additional Content'), // New Text field
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
