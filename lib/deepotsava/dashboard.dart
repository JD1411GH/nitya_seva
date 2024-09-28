import 'package:flutter/material.dart';
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

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  void addLampsServed(int lamps) {
    print("Adding $lamps lamps");
    setState(() {
      _lampsIssued += lamps;
    });
  }

  Widget _createLampCount(double height) {
    return Center(
      child: Container(
        height: height,
        width: height,
        child: CircleAvatar(
          radius: height / 2,
          child: Text(
            '$_lampsIssued',
            style: TextStyle(fontSize: 32.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = 100;

    return FutureBuilder<void>(
      future: _futureInit(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return SizedBox(
              height: height,
              child: Card(
                child: _createLampCount(height),
              ));
        }
      },
    );
  }
}
