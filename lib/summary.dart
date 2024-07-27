import 'package:flutter/material.dart';

Future<void> _futureInit() async {
  // Simulate a network call or any asynchronous operation
  await Future.delayed(Duration(seconds: 2));
}

class Summary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Page'),
      ),
      body: FutureBuilder<void>(
        future: _futureInit(), // The future to listen to
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error message if any
          } else {
            return const Center(child: Text('Result')); // Show the fetched data
          }
        },
      ),
    );
  }
}
