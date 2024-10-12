import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/log_dialog.dart';

class Log extends StatefulWidget {
  final String stall;

  const Log({super.key, required this.stall});

  @override
  State<Log> createState() => _LogState();
}

final GlobalKey<_LogState> logKey = GlobalKey<_LogState>();

class _LogState extends State<Log> {
  List<DeepamSale> cardValues = [];

  DateTime _localUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    refresh();

    // subscribe for updates on sales
    FBL().listenForChange(
        "deepotsava/${widget.stall}/sales",
        FBLCallbacks(
          // callback for adding a new sale
          add: (dynamic data) async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            DeepamSale sale = DeepamSale.fromJson(map);
            addLog(sale, localUpdate: false);
          },

// callback for adding a new sale
          delete: (dynamic data) async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            // Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
            // DeepamSale sale = DeepamSale.fromJson(map);
            // addLog(sale, localUpdate: false);
          },

          // callback for editing a sale
          edit: () async {
            // skip refresh if already updated locally
            if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) {
              return;
            }

            await refresh();
            setState(() {});
          },
        ));
  }

  void addLog(DeepamSale sale, {bool localUpdate = false}) {
    setState(() {
      cardValues.insert(0, sale);
    });

    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  Future<void> refresh() async {
    cardValues = await FBL().getSales(widget.stall);
    cardValues.sort((a, b) => b.timestamp.compareTo(a.timestamp));
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
      // row of tiles
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardValues.map((value) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogDialog(
                    sale: value,
                    callbacks: LogCallbacks(
                        edit: (DeepamSale data, {bool? localUpdate}) {
                      setState(() {
                        // update log
                        cardValues.removeWhere(
                            (element) => element.timestamp == data.timestamp);
                        cardValues.insert(0, data);
                        cardValues
                            .sort((a, b) => b.timestamp.compareTo(a.timestamp));

                        // update database
                        FBL().editSale(widget.stall, data);

                        // due to complexity, not adding any extra logic to locally update other widgets.
                        // this will be handled by the FBL callback
                      });

                      // update database
                    }, delete: (DeepamSale data, {bool? localUpdate}) {
                      // update UI
                      setState(() {
                        cardValues.removeWhere(
                            (element) => element.timestamp == data.timestamp);
                      });

                      // update database
                      FBL().deleteSale(widget.stall, data);

                      // due to complexity, not adding any extra logic to locally update other widgets.
                      // this will be handled by the FBL callback
                    }),
                  );
                },
              );
            },
            child: Card(
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
                      // top row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // payment mode icon
                          Flexible(
                            child: Image.asset(
                              _getPaymentIcon(value.paymentMode),
                              height: 12,
                            ),
                          ),

                          SizedBox(
                            width: 4,
                          ),

                          // time
                          Text(
                            "${value.timestamp.hour}:${value.timestamp.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      // centre widget for count
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

                      // sevakarta
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
