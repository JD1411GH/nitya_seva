import 'package:flutter/material.dart';

class Pushpanjali extends StatefulWidget {
  const Pushpanjali({super.key});

  @override
  State<Pushpanjali> createState() => _WidgetTemplateState();
}

class _WidgetTemplateState extends State<Pushpanjali> {
  Future<void> _futureInit() async {
    await Future.delayed(const Duration(seconds: 2));
    // Add your initialization code here
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
