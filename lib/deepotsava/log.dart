import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';

class Log extends StatefulWidget {
  final String stall;

  const Log({super.key, required this.stall});

  @override
  State<Log> createState() => _LogState();
}

final GlobalKey<_LogState> LogKey = GlobalKey<_LogState>();

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cardValues.map((value) {
          return Card(
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
                    Text(
                      "${value.timestamp.hour}:${value.timestamp.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 12),
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
                    Text(
                      "${value.paymentMode}",
                      style: TextStyle(fontSize: 12),
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
