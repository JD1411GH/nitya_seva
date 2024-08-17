import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

class Pushpanjali extends StatefulWidget {
  const Pushpanjali({super.key});

  @override
  State<Pushpanjali> createState() => _WidgetTemplateState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_WidgetTemplateState> templateKey =
    GlobalKey<_WidgetTemplateState>();

class _WidgetTemplateState extends State<Pushpanjali> {
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
