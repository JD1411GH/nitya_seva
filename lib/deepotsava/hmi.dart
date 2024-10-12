import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:garuda/const.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';
import 'package:garuda/toaster.dart';
import 'package:garuda/utils.dart';

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
  int _count = 0;
  String _selectedMode = "";
  String _user = "Unknown";
  int _plate = 0;
  int _amount = 0;

  Color? _themeColor;
  Color? _textColor;
  Color? _bgColor;

  FixedExtentScrollController _cupertinoController =
      FixedExtentScrollController(initialItem: 0);

  int _stockAvailable = 0;

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
      _themeColor = primaryColorDefault;
      _textColor = Colors.black;
      _bgColor = Colors.grey;
    }

    Utils().getUserName().then((value) {
      _user = value;
    });

    // get the available lamp stock
    _recalculateStock();

    // subscribe for updates in stock
    FBL().listenForChange(
        "deepotsava/${widget.stall}/stocks",
        FBLCallbacks(
          // callback for adding a new stock
          add: (dynamic data) async {
            Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            DeepamStock stock = DeepamStock.fromJson(map);
            _addStock(stock);
          },

          // callback for deleting a stock
          delete: (dynamic data) async {
            Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            DeepamStock stock = DeepamStock.fromJson(map);
            _stockAvailable -= stock.preparedLamps + stock.unpreparedLamps;
          },

          // callback for editing a stock
          edit: () async {
            _recalculateStock();
          },
        ));
  }

  Future<void> _recalculateStock() async {
    List<DeepamStock> stocks = await FBL().getStocks(widget.stall);
    List<DeepamSale> sales = await FBL().getSales(widget.stall);

    // reset the availability bar variables
    _stockAvailable = 0;

    stocks.forEach((stock) {
      // update the availability bar variables
      _stockAvailable += stock.preparedLamps + stock.unpreparedLamps;
    });

    // update the availability bar variables for sales
    sales.forEach((sale) {
      _stockAvailable -= sale.count;
    });
  }

  void _recalculateAmount() {
    if (_selectedMode == "Gift") {
      _amount = 0;
    } else
      _amount = (_cupertinoController.selectedItem *
              Const().deepotsava['lamp']['cost'] as int) +
          (_plate * Const().deepotsava['plate']['cost'] as int);
  }

  void _addStock(DeepamStock stock) {
    _stockAvailable += stock.preparedLamps + stock.unpreparedLamps;
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
              color: _count == num && _selectedMode == mode
                  ? _themeColor
                  : Colors.transparent),
          padding: EdgeInsets.all(8.0), // Add padding inside the border
          child: Text(
            '$num',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _count == num && _selectedMode == mode
                    ? Colors.white
                    : _textColor),
          ),
        ),
        onTap: () {
          if (!mounted) return;
          setState(() {
            _count = num;
            _selectedMode = mode;

            // change cupertino
            _cupertinoController.jumpToItem(num);

            // recalculate amount
            _recalculateAmount();
          });
        },
        onLongPress: () {
          DeepamSale sale = DeepamSale(
            timestamp: DateTime.now(),
            stall: widget.stall,
            count: num,
            costLamp:
                mode == "Gift" ? 0 : Const().deepotsava['lamp']['cost'] as int,
            costPlate:
                mode == "Gift" ? 0 : Const().deepotsava['plate']['cost'] as int,
            paymentMode: mode,
            user: _user,
            plate: _plate,
          );

          _addSale(sale);
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
                  if (!mounted) return;

                  setState(() {
                    _selectedMode = mode;
                    _recalculateAmount();
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
        if (!mounted) return;

        if (_selectedMode == "") {
          _selectedMode = "Cash";
        }

        _recalculateAmount();

        setState(() {});
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

  void _addSale(DeepamSale sale) {
    if (sale.plate == 0 && sale.count == 0) {
      return;
    }

    // return if not enough stock
    if (_stockAvailable < sale.count) {
      Toaster().error("Not enough stock");
      return;
    }

    // update stock
    _stockAvailable -= sale.count;

    // update all dependent widgets
    widget.callbacks.add(sale);

    // update FB asynchronously
    FBL().addSale(widget.stall, sale);

    // reset all selections
    _cupertinoController.jumpToItem(0);
    if (!mounted) return;
    setState(() {
      _count = 0;
      _selectedMode = "";
      _plate = 0;
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
                  // reset button
                  IconButton(
                    icon: Icon(Icons.refresh),
                    iconSize: 24.0,
                    onPressed: () {
                      if (!mounted) return;

                      setState(() {
                        _cupertinoController.jumpToItem(0);
                        _count = 0;
                        _selectedMode = "";
                        _plate = 0;
                        _amount = 0;
                      });
                    },
                  ),

                  // SizedBox(width: 18),

                  // Plate toggle
                  GestureDetector(
                    onTap: () {
                      if (!mounted) return;

                      setState(() {
                        _plate = _plate > 0 ? 0 : 1;

                        if (_plate > 0) {
                          if (_selectedMode == "") {
                            _selectedMode = "Cash";
                          }
                        }

                        _recalculateAmount();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: _plate > 0
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
                          color: _plate > 0
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

                  // Amount
                  Container(
                    width: 50,
                    child: Text(
                      '₹${_amount}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  // serve button
                  IconButton(
                    icon: Icon(Icons.send),
                    iconSize: 24.0,
                    onPressed: () {
                      DeepamSale sale = DeepamSale(
                        timestamp: DateTime.now(),
                        stall: widget.stall,
                        count: _cupertinoController.selectedItem,
                        costLamp: _selectedMode == "Gift"
                            ? 0
                            : Const().deepotsava['lamp']['cost'] as int,
                        costPlate: _selectedMode == "Gift"
                            ? 0
                            : Const().deepotsava['plate']['cost'] as int,
                        paymentMode: _selectedMode,
                        user: _user,
                        plate: _plate,
                      );

                      _addSale(sale);
                      _recalculateAmount();
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
