import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

GlobalKey<_SummaryState> summaryKey = GlobalKey<_SummaryState>();

class _SummaryState extends State<Summary> {
  final Lock _lock = Lock();

  @override
  void initState() {
    super.initState();

    refresh();
  }

  void refresh() async {
    await _lock.synchronized(() async {
      // all you need to do
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
