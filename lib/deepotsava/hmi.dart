import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter/cupertino.dart';

class HMI extends StatefulWidget {
  const HMI({super.key});

  @override
  State<HMI> createState() => _HMIState();
}

// hint: templateKey.currentState!.refresh();
final GlobalKey<_HMIState> templateKey = GlobalKey<_HMIState>();

class _HMIState extends State<HMI> {
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

  Widget _createNumberButton(int num) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text('$num'),
    );
  }

  Widget _createMainWidget() {
    return Stack(
      children: [
        // UPI corner
        Positioned(
          top: 10,
          left: 10,
          child: Column(
            children: [
              Text('UPI'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(5),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Cash corner
        Positioned(
          bottom: 10,
          left: 10,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(5),
                  ),
                ],
              ),
              Text('Cash'),
            ],
          ),
        ),

        // Card corner
        Positioned(
          top: 10,
          right: 10,
          child: Column(
            children: [
              Text('Card'),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(5),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Gratis corner
        Positioned(
          bottom: 10,
          right: 10,
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(1),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _createNumberButton(5),
                  ),
                ],
              ),
              Text('Gratis'),
            ],
          ),
        ),

        // Text field
        Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // text field
              SizedBox(
                width: 80, // Adjust the width to match the button
                height: 60, // Adjust the height to match the button
                child: CupertinoPicker(
                  itemExtent: 32.0, // Height of each item
                  onSelectedItemChanged: (int index) {
                    // Handle the selected item change
                  },
                  children: List<Widget>.generate(100, (int index) {
                    return Center(
                      child: Text(
                        index.toString(),
                        style: TextStyle(
                            fontSize:
                                32.0), // Increase the font size of the text
                      ),
                    );
                  }),
                ),
              ),

              // Add padding between the picker and the button
              SizedBox(height: 16), // Adjust the height as needed

              // serve button
              ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(40, 40), // Small size
                ),
                child: Text('+'),
              )
            ],
          ),
        ),
      ],
    );
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
          return Card(
              child: SizedBox(
            height: 180.0,
            child: _createMainWidget(),
          ));
        }
      },
    );
  }
}
