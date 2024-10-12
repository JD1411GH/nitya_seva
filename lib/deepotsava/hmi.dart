import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
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
  String _user = "Unknown";
  bool _plateEnabled = false;

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

    Const().getUserName().then((value) {
      _user = value;
    });
  }

  Widget _createAmountButton(int num, String mode) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black), // Add border here
              borderRadius:
                  BorderRadius.circular(8.0), // Make the border rounded
              color: _selectedAmount == num && _selectedMode == mode
                  ? _themeColor
                  : Colors.transparent),
          padding: EdgeInsets.all(8.0), // Add padding inside the border
          child: Text(
            '$num',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _selectedAmount == num && _selectedMode == mode
                    ? Colors.white
                    : _textColor),
          ),
        ),
        onTap: () {
          setState(() {
            _selectedAmount = num;
            _selectedMode = mode;

            // change cupertino
            int currentValue = _cupertinoController.selectedItem;
            _cupertinoController.jumpToItem(currentValue + num);
          });
        },
        onLongPress: () {
          _addSale(num, mode);
        },
      ),
    );
  }

  Widget _createPaymentWidget(String mode) {
    String iconFile;
    switch (mode) {
      case 'UPI':
        iconFile = 'assets/images/icon_upi.png';
      case 'Cash':
        iconFile = 'assets/images/icon_cash.png';
      case 'Card':
        iconFile = 'assets/images/icon_card.png';
      default:
        iconFile = 'assets/images/icon_gratis.png'; // gift
    }

    return Container(
      decoration: BoxDecoration(
        color: _selectedMode == mode ? _bgColor : Colors.transparent,
        border: Border.all(color: Colors.black), // Add border here
        borderRadius: BorderRadius.circular(8.0), // Make the border rounded
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMode = mode;
                  });
                },
                child: Container(
                  width: 50,
                  child: Column(
                    children: [
                      Image.asset(
                        iconFile,
                        fit: BoxFit.contain,
                        height: 24.0, // Adjust the height as needed
                      ),
                      Center(child: Text(mode)),
                    ],
                  ),
                ),
              ),
              _createAmountButton(1, mode),
              _createAmountButton(2, mode),
            ],
          ),
          Row(
            children: [
              _createAmountButton(3, mode),
              _createAmountButton(4, mode),
              _createAmountButton(5, mode),
            ],
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

  void _addSale(int count, mode) {
    DeepamSale sale = DeepamSale(
      timestamp: DateTime.now(),
      stall: widget.stall,
      count: count,
      costLamp: Const().deepotsava['lamp']['cost'] as int,
      costPlate: Const().deepotsava['plate']['cost'] as int,
      paymentMode: mode,
      user: _user,
      plate: _plateEnabled,
    );

    // update all dependent widgets
    widget.callbacks.add(sale);

    // update FB asynchronously
    FBL().addSale(widget.stall, sale);

    // reset all selections
    _cupertinoController.jumpToItem(0);
    setState(() {
      _selectedAmount = 0;
      _selectedMode = "";
      _plateEnabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        constraints:
            BoxConstraints(minHeight: 320), // Define minimum height here
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Plate toggle
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _plateEnabled = !_plateEnabled;

                        if (_plateEnabled && _selectedMode == "") {
                          _selectedMode = "Cash";
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: _plateEnabled
                            ? (widget.stall == "RRG"
                                ? primaryColorRRG
                                : primaryColorRKC)
                            : Colors.transparent,
                        border: Border.all(color: Colors.black),
                        borderRadius:
                            BorderRadius.circular(8.0), // Rounded border
                      ),
                      child: Text(
                        'Plate',
                        style: TextStyle(
                          color: _plateEnabled
                              ? Colors.white
                              : Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                    ),
                  ),

                  // count field
                  SizedBox(
                    width: 80,
                    height: 60,
                    child: _createCupertino(),
                  ),

                  // Add padding between the picker and the button
                  SizedBox(height: 16), // Adjust the height as needed

                  // serve button
                  IconButton(
                    icon: Icon(Icons.send),
                    iconSize: 24.0, // Adjust the size as needed
                    onPressed: () {
                      _addSale(
                          _cupertinoController.selectedItem, _selectedMode);
                    },
                  )
                ],
              ),
            ),

            // UPI corner
            Positioned(
              top: 70,
              left: 10,
              child: _createPaymentWidget("UPI"),
            ),

            // Cash corner
            Positioned(
              bottom: 10,
              left: 10,
              child: _createPaymentWidget("Cash"),
            ),

            // Card corner
            Positioned(
              top: 70,
              right: 10,
              child: _createPaymentWidget("Card"),
            ),

            // Gift corner
            Positioned(
              bottom: 10,
              right: 10,
              child: _createPaymentWidget("Gift"),
            ),

            // dummy text to prevent crash
            Text('')
          ],
        ),
      ),
    );
  }
}

class HMICallbacks {
  void Function(DeepamSale) add;
  // void Function(DeepamStock data) edit;
  // void Function(DeepamStock data) delete;

  HMICallbacks({
    required this.add,
  });
}
