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
  String _selectedMode = "";
  Color? _themeColor;
  Color? _textColor;
  Color? _bgColor;

  @override
  initState() {
    super.initState();

    if (widget.stall == 'RRG') {
      _themeColor = primaryColorRRG;
      _textColor = textColorRRG ?? Colors.black;
      _bgColor = variantColorRRG;
    } else if (widget.stall == 'RKC') {
      _themeColor = primaryColorRKC;
      _textColor = textColorRKC;
      _bgColor = variantColorRKC;
    } else {
      _themeColor = primaryColor;
      _textColor = Colors.black;
      _bgColor = Colors.grey;
    }
  }

  Widget _createAmountButton(int num, String mode) {
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
              ? _themeColor
              : Colors.transparent,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          '$num',
          style: TextStyle(
              color: _selectedAmount == num && _selectedMode == mode
                  ? Colors.white
                  : _textColor), // Change 'Colors.red' to your desired color
        ),
      ),
    );
  }

  Widget _createPaymentWidget(String mode, String titlePosition) {
    return Container(
      color: _selectedMode == mode
          ? _bgColor
          : Colors.transparent, // Set your desired background color here
      child: Column(
        children: [
          if (titlePosition == "top") Text(mode),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createAmountButton(1, mode),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createAmountButton(2, mode),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _createAmountButton(5, mode),
              ),
            ],
          ),
          if (titlePosition == "bottom") Text(mode),
        ],
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
          child: _createPaymentWidget("UPI", "top"),
        ),

        // Cash corner
        Positioned(
          bottom: 10,
          left: 10,
          child: _createPaymentWidget("Cash", "bottom"),
        ),

        // Card corner
        Positioned(
          top: 10,
          right: 10,
          child: _createPaymentWidget("Card", "top"),
        ),

        // Gratis corner
        Positioned(
          bottom: 10,
          right: 10,
          child: _createPaymentWidget("Gratis", "bottom"),
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
