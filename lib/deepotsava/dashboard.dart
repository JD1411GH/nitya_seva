import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:synchronized/synchronized.dart';

class Dashboard extends StatefulWidget {
  final String stall;

  const Dashboard({super.key, required this.stall});

  @override
  State<Dashboard> createState() => _DashboardState();
}

// hint: dashboardKey.currentState!.refresh();
final GlobalKey<_DashboardState> dashboardKey = GlobalKey<_DashboardState>();

class _DashboardState extends State<Dashboard> {
  final _lockInit = Lock();
  int _lampsIssued = 0;
  int _platesIssued = 0;
  Map<String, int> _modeCount = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  void addLampsServed(DeepamSale sale) {
    setState(() {
      _lampsIssued += sale.count;
      sale.plate ? _platesIssued++ : null;

      if (_modeCount.containsKey(sale.paymentMode)) {
        _modeCount[sale.paymentMode] = _modeCount[sale.paymentMode]! + 1;
      } else {
        _modeCount[sale.paymentMode] = 1;
      }
    });
  }

  Widget _createLampCount(double height) {
    return Container(
      height: height,
      width: height,
      child: CircleAvatar(
        radius: height / 2,
        child: Text(
          '$_lampsIssued',
          style: TextStyle(fontSize: 32.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = 100;

    return SizedBox(
      height: height,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0), // Add horizontal padding
          child: Row(
            children: [
              // left side widget
              Container(
                height: height,
                width: height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Lamps: $_lampsIssued"),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Plates: $_platesIssued"),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Amount: Rs. 0"),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(),

              // center widget
              Center(
                child: _createLampCount(height),
              ),

              Spacer(),

              // right side widget
              Container(
                height: height,
                width: height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _modeCount.entries.map((entry) {
                      return Flexible(
                        child: Text("${entry.key}: ${entry.value}"),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}