import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:garuda/theme.dart';

class HMI extends StatefulWidget {
  final String stall;
  final HMICallbacks callbacks;
  const HMI({super.key, required this.stall, required this.callbacks});

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

  FixedExtentScrollController _cupertinoController =
      FixedExtentScrollController(initialItem: 0);

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

          // change cupertino
          int currentValue = _cupertinoController.selectedItem;
          _cupertinoController.jumpToItem(currentValue + num);
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
          if (titlePosition == "top")
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMode = mode;
                });
              },
              child: Text(mode),
            ),
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
          if (titlePosition == "bottom")
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMode = mode;
                });
              },
              child: Text(mode),
            ),
        ],
      ),
    );
  }

  Widget _createCupertino() {
    return CupertinoPicker(
      scrollController: _cupertinoController,
      itemExtent: 32.0,
      onSelectedItemChanged: (int index) {
        if (_selectedMode == "") {
          setState(() {
            _selectedMode = "Cash";
          });
        }

        setState(() {
          _selectedAmount = index;
        });
      },
      children: List<Widget>.generate(100, (int index) {
        return Center(
          child: Text(
            index.toString(),
            style:
                TextStyle(fontSize: 32.0), // Increase the font size of the text
          ),
        );
      }),
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
                width: 80,
                height: 60,
                child: _createCupertino(),
              ),

              // Add padding between the picker and the button
              SizedBox(height: 16), // Adjust the height as needed

              // serve button
              ElevatedButton(
                onPressed: () {
                  widget.callbacks.add(_selectedAmount);
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

class HMICallbacks {
  void Function(int count) add;
  // void Function(DeepamStock data) edit;
  // void Function(DeepamStock data) delete;

  HMICallbacks({
    required this.add,
  });
}
