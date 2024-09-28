import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:garuda/theme.dart';

class HMI extends StatefulWidget {
  final String stall;
  const HMI({super.key, required this.stall});

  @override
  State<HMI> createState() => _HMIState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_HMIState> templateKey = GlobalKey<_HMIState>();

class _HMIState extends State<HMI> {
  int _selectedAmount = 0;
  String _selectedMode = "UPI";

  Widget _createAmountButton(int num, String mode) {
    Color themeColor;
    Color textColor;
    if (widget.stall == 'RRG') {
      themeColor = primaryColorRRG;
      textColor = textColorRRG ?? Colors.black;
    } else if (widget.stall == 'RKC') {
      themeColor = primaryColorRKC;
      textColor = textColorRKC;
    } else {
      themeColor = Colors.transparent;
      textColor = Colors.black;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAmount = num;
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: _selectedAmount == num && _selectedMode == mode
              ? themeColor
              : Colors.transparent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          '$num',
          style: TextStyle(
              color: _selectedAmount == num && _selectedMode == mode
                  ? Colors.white
                  : textColor), // Change 'Colors.red' to your desired color
        ),
      ),
    );
  }

  Widget _createMainWidget() {
    return Stack(
      children: [
        // UPI corner
        Positioned(
          top: 10,
          left: 10,
          child: Column(
            children: [
              Text('UPI'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(1, "UPI"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(2, "UPI"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(5, "UPI"),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cash corner
        Positioned(
          bottom: 10,
          left: 10,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(1, "Cash"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(2, "Cash"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(5, "Cash"),
                  ),
                ],
              ),
              Text('Cash'),
            ],
          ),
        ),

        // Card corner
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              Text('Card'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(1, "Card"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(2, "Card"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(5, "Card"),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Gratis corner
        Positioned(
          bottom: 10,
          right: 10,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(1, "Gratis"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(2, "Gratis"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createAmountButton(5, "Gratis"),
                  ),
                ],
              ),
              Text('Gratis'),
            ],
          ),
        ),

        // Text field
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // text field
              SizedBox(
                width: 80, // Adjust the width to match the button
                height: 60, // Adjust the height to match the button
                child: CupertinoPicker(
                  itemExtent: 32.0, // Height of each item
                  onSelectedItemChanged: (int index) {
                    // Handle the selected item change
                  },
                  children: List<Widget>.generate(100, (int index) {
                    return Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                            fontSize:
                                32.0), // Increase the font size of the text
                      ),
                    );
                  }),
                ),
              ),

              // Add padding between the picker and the button
              SizedBox(height: 16), // Adjust the height as needed

              // serve button
              ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 40), // Small size
                ),
                child: Text('+'),
              )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 180.0,
        child: _createMainWidget(),
      ),
    );
  }
}
