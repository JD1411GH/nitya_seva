import 'package:flutter/material.dart';
import 'package:garuda/deepotsava/mode_chart.dart';
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

  @override
  void initState() {
    super.initState();
  }

  Future<void> refresh() async {
    setState(() {});
  }

  void addLampsServed(int lamps) {
    setState(() {
      _lampsIssued += lamps;
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
                color: Colors.grey[300], // Placeholder widget on the left
                child: Center(
                  child: Text(
                    'Placeholder',
                    style: TextStyle(fontSize: 16.0),
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
              SizedBox(
                height: height,
                width: height,
                child: ModeChart(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
