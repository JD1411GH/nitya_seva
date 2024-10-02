import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/theme.dart';

class Log extends StatefulWidget {
  final String stall;

  const Log({super.key, required this.stall});

  @override
  State<Log> createState() => _LogState();
}

final GlobalKey<_LogState> logKey = GlobalKey<_LogState>();

class _LogState extends State<Log> {
  List<DeepamSale> cardValues = [];

  @override
  void initState() {
    super.initState();

    refresh();
  }

  void addLog(DeepamSale sale) {
    setState(() {
      cardValues.add(sale);
    });
  }

  Future<void> refresh() async {
    cardValues = await FBL().getSales(widget.stall);
    setState(() {});
  }

  String _getPaymentIcon(String paymentMode) {
    switch (paymentMode) {
      case 'UPI':
        return 'assets/images/icon_upi.png';
      case 'Cash':
        return 'assets/images/icon_cash.png';
      case 'Card':
        return 'assets/images/icon_card.png';
      default:
        return 'assets/images/icon_gratis.png'; // gift
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColorPlate;
    if (widget.stall == 'RRG') {
      bgColorPlate = Colors.green[100] ?? Colors.grey;
    } else if (widget.stall == 'RKC') {
      bgColorPlate = Colors.orange[100] ?? Colors.grey;
    } else {
      bgColorPlate = Colors.grey;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardValues.map((value) {
          return Card(
            color: value.plate ? bgColorPlate : Colors.white,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SizedBox(
              width: 100.0,
              height: 100.0,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Image.asset(
                            _getPaymentIcon(value.paymentMode),
                            height: 12,
                          ),
                        ),
                        SizedBox(
                          width:
                              4, // Add some spacing between the image and the text
                        ),
                        Text(
                          "${value.timestamp.hour}:${value.timestamp.minute.toString().padLeft(2, '0')}",
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      child: Text(
                        "${value.count}",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        "${value.user}",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
