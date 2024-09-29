import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';

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

  Color _getBackgroundColor(String paymentMode) {
    switch (paymentMode) {
      case 'UPI':
        return Colors.orange[100] ?? Colors.orange;
      case 'Cash':
        return Colors.green[50] ?? Colors.green;
      case 'Card':
        return Colors.blue[50] ?? Colors.blue;
      case 'Gift':
        return Colors.grey[50] ?? Colors.grey;
      default:
        return Colors.white;
    }
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
        return 'assets/images/icon_gratis.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardValues.map((value) {
          return Card(
            color: _getBackgroundColor(value.paymentMode),
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
                            _getPaymentIcon(value
                                .paymentMode), // Replace with your image path
                            height:
                                12, // Adjust the height to match the text size
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
