import 'package:flutter/material.dart';
import 'package:garuda/pushpanjali/dashboard.dart';

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

  Future<void> _handleRefresh() async {
    await _futureInit();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: FutureBuilder<void>(
        future: _futureInit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Pushpanjali'),
              ),
              body: const Dashboard(),
            );
          }
        },
      ),
    );
  }
}
