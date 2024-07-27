import 'package:flutter/material.dart';
import 'package:nitya_seva/local_storage.dart';
import 'package:nitya_seva/toaster.dart';

class Summary extends StatefulWidget {
  const Summary({super.key});

  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  DateTime? timestampSlot;
  List<String> items = [];

  Future<void> _futureInit() async {
    String? str = await LS().read('selectedSlot');

    if (str != null) {
      timestampSlot = DateTime.parse(str);
      items = List.generate(10, (index) => 'Item $index');
    } else {
      Toaster().error("Error reading local storage");
    }
  }

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
            return ListView.builder(
              itemCount: items.length, // Number of items in the list
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0), // Adjust margin to remove top gap
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for the container
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    border: Border.all(
                      color: Colors.grey, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double
                            .infinity, // Make the title container fill the entire width
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors
                              .blue, // Solid background color for the title
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                8.0), // Rounded corners for the top left
                            topRight: Radius.circular(
                                8.0), // Rounded corners for the top right
                          ),
                        ),
                        child: Text(
                          'Title ${items[index]}', // Display the title
                          style: const TextStyle(
                            color: Colors.white, // Text color for the title
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                          height:
                              8.0), // Add some space between the title and the rows of text
                      Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Add padding inside the tile
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Row 1: Details for ${items[index]}', // First row of text
                              style: const TextStyle(
                                color: Colors
                                    .black, // Text color for the rows of text
                              ),
                            ),
                            Text(
                              'Row 2: More details for ${items[index]}', // Second row of text
                              style: const TextStyle(
                                color: Colors
                                    .black, // Text color for the rows of text
                              ),
                            ),
                            Text(
                              'Row 3: Additional details for ${items[index]}', // Third row of text
                              style: const TextStyle(
                                color: Colors
                                    .black, // Text color for the rows of text
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ); // Show the fetched data
          }
        },
      ),
    );
  }
}
