import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/datatypes.dart';
import 'package:garuda/deepotsava/fbl.dart';

class Dashboard extends StatefulWidget {
  final String stall;

  const Dashboard({super.key, required this.stall});

  @override
  State<Dashboard> createState() => _DashboardState();
}

// hint: dashboardKey.currentState!.refresh();
final GlobalKey<_DashboardState> dashboardKey = GlobalKey<_DashboardState>();

class _DashboardState extends State<Dashboard> {
  int _lampsIssued = 0;
  int _platesIssued = 0;
  int _amountCollected = 0;
  Map<String, int> _modeCount = {};

  DateTime _localUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    refresh();

    // subscribe for updates
    FBL().listenForChange(
        "deepotsava/${widget.stall}/sales",
        FBLCallbacks(
            // add
            add: (data) async {
          if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) return;

          Map<String, dynamic> map = Map<String, dynamic>.from(data as Map);
          DeepamSale sale = DeepamSale.fromJson(map);
          addLampsServed(sale, localUpdate: false);
        },

            // edit
            edit: () async {
          if (DateTime.now().difference(_localUpdateTime).inSeconds < 1) return;

          refresh();
        }));
  }

  Future<void> refresh() async {
    List<DeepamSale> sales = await FBL().getSales(widget.stall);

    setState(() {
      _lampsIssued = 0;
      _platesIssued = 0;
      _amountCollected = 0;
      _modeCount = {};
      sales.forEach((sale) {
        if (sale.count > 0) {
          _lampsIssued += sale.count;
          _amountCollected += (sale.count * sale.costLamp);
        }

        if (sale.plate) {
          _platesIssued++;
          _amountCollected += sale.costPlate;
        }

        if (_modeCount.containsKey(sale.paymentMode)) {
          _modeCount[sale.paymentMode] = _modeCount[sale.paymentMode]! + 1;
        } else {
          _modeCount[sale.paymentMode] = 1;
        }
      });
    });
  }

  void addLampsServed(DeepamSale sale, {bool localUpdate = true}) {
    setState(() {
      _lampsIssued += sale.count;
      sale.plate ? _platesIssued++ : null;

      if (_modeCount.containsKey(sale.paymentMode)) {
        _modeCount[sale.paymentMode] = _modeCount[sale.paymentMode]! + 1;
      } else {
        _modeCount[sale.paymentMode] = 1;
      }

      // update amount
      _amountCollected += (sale.count * sale.costLamp);
      sale.plate ? _amountCollected += sale.costPlate : null;
    });

    if (localUpdate) {
      _localUpdateTime = DateTime.now();
    }
  }

  Widget _createLampCount(double height) {
    _localUpdateTime = DateTime.now();

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
                        child: Text("Amt: ₹$_amountCollected"),
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
