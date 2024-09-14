import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class Stats extends StatefulWidget {
  final String stall;
  const Stats({super.key, required this.stall});

  @override
  State<Stats> createState() => _StatsState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_StatsState> templateKey = GlobalKey<_StatsState>();

class _StatsState extends State<Stats> {
  final _lockInit = Lock();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
          return const Placeholder();
        }
      },
    );
  }
}
