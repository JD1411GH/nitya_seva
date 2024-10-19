import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/sales/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';
import 'package:garuda/deepotsava/sales/log_dialog.dart';
import 'package:garuda/theme.dart';
import 'package:garuda/toaster.dart';

class Log extends StatefulWidget {
  final String stall;
  final LogCallbacks callbacks;

  const Log({super.key, required this.stall, required this.callbacks});

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
            if (!mounted) return;
            setState(() {});
          },
        ));
  }

  void addLog(DeepamSale sale, {bool localUpdate = false}) {
    if (!mounted) return;
    setState(() {
      cardValues.insert(0, sale);
    });

    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  void editLog(DeepamSale data, {bool? localUpdate}) {
    if (!mounted) return;
    setState(() {
      // update log
      cardValues.removeWhere((element) => element.timestamp == data.timestamp);
      cardValues.insert(0, data);
      cardValues.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // update database
      FBL().editSale(widget.stall, data);

      // due to complexity, not adding any extra logic to locally update other widgets.
      // this will be handled by the FBL callback
    });

    widget.callbacks.edit(data);
  }

  void deleteLog(DeepamSale data, {bool? localUpdate}) {
    // update UI
    if (!mounted) return;
    setState(() {
      cardValues.removeWhere((element) => element.timestamp == data.timestamp);
    });

    // update database
    FBL().deleteSale(widget.stall, data);

    // design decision:
    // due to complexity, not adding any extra logic to locally update other widgets.
    // this will be handled by the FBL callback

    widget.callbacks.delete(data);
  }

  Future<void> refresh() async {
    cardValues = await FBL().getSales(widget.stall);
    cardValues.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (!mounted) return;
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
      case 'Gift':
        return 'assets/images/icon_gratis.png';
      case 'Discard':
        return 'assets/images/icon_discard.png';
      default:
        Toaster().error("Unknown payment mode: $paymentMode");
        return 'assets/images/icon_discard.png';
    }
  }

  @override
  Widget build(BuildContext context) {
// Select theme based on the value of stall
    Color bgColor;
    if (widget.stall == 'RRG') {
      bgColor = variantColorRRG ?? Colors.grey;
    } else if (widget.stall == 'RKC') {
      bgColor = variantColorRKC ?? Colors.grey;
    } else {
      bgColor = variantColorDefault ?? Colors.grey;
    }

    return SingleChildScrollView(
      // row of tiles
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardValues.map((value) {
          int amount =
              (value.count * value.costLamp) + (value.plate * value.costPlate);

          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return LogDialog(
                    sale: value,
                    callbacks:
                        LogDialogCallbacks(edit: editLog, delete: deleteLog),
                  );
                },
              );
            },

            // individual log card
            child: Card(
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
                      // top row for time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // time
                          Text(
                            "${value.timestamp.hour}:${value.timestamp.minute.toString().padLeft(2, '0')}",
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      // centre widget for count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                              color: value.plate > 0
                                  ? bgColor
                                  : Colors.transparent,
                            ),
                            child: Text(
                              "${value.count}",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),

                          SizedBox(width: 8),

                          // payment
                          Column(
                            children: [
                              // payment mode icon
                              Image.asset(
                                _getPaymentIcon(value.paymentMode),
                                fit: BoxFit.scaleDown,
                                height: 18,
                              ),

                              // amount
                              Text(
                                "₹$amount",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          )
                        ],
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

class LogCallbacks {
  void Function(DeepamSale data) edit;
  void Function(DeepamSale data) delete;

  LogCallbacks({
    required this.edit,
    required this.delete,
  });
}
