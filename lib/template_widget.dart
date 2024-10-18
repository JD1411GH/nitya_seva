import 'package:flutter/material.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  State<Summary> createState() => _SummaryState();
}

GlobalKey<_SummaryState> summaryKey = GlobalKey<_SummaryState>();

class _SummaryState extends State<Summary> {
  @override
  void initState() {
    super.initState();

    refresh();
  }

  void refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
