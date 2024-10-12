import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class StatsPage extends StatefulWidget {
  final String stall;
  const StatsPage({super.key, required this.stall});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_StatsPageState> templateKey = GlobalKey<_StatsPageState>();

class _StatsPageState extends State<StatsPage> {
  final _lockInit = Lock();

  Future<void> _futureInit() async {
    await _lockInit.synchronized(() async {
      await Future.delayed(const Duration(seconds: 2));
    });
  }

  Future<void> refresh() async {
    await _futureInit();
    if (!mounted) return;
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
