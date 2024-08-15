import 'package:flutter/material.dart';

class Stock extends StatefulWidget {
  @override
  _StockState createState() => _StockState();
}

class _StockState extends State<Stock> {
  final primaryColor = Colors.green;
  bool isCollapsed = false;
  int total_procured = 0;
  int total_distributed = 0;
  int procured_today = 0;
  int distributed_today = 0;

  Future<void> fetchData() async {
    setState(() {
      total_procured = 100;
      total_distributed = 50;
      procured_today = 10;
      distributed_today = 5;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Padding(
            padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0), // Reduced padding to the top, left, and right
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Take only the space needed by children
                children: [
                  // title bar
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isCollapsed =
                            !isCollapsed; // Toggle the collapsed state
                      });
                    },
                    child: Container(
                      color: primaryColor, // Dark background for the title
                      width:
                          double.infinity, // Fill the entire horizontal space
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Stock Management',
                        style: TextStyle(
                          color: Colors.white, // Set the text color to white
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold, // Make the text bold
                        ),
                      ),
                    ),
                  ),

                  if (!isCollapsed)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // total procured
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total procured = $total_procured packs',
                            ),
                          ),

                          // total distributed
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total distributed = $total_distributed packs',
                            ),
                          ),

                          // procured today
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Procured today = $procured_today packs',
                            ),
                          ),

                          // distributed today
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Distributed today = $distributed_today packs',
                            ),
                          ),

                          Divider(),

                          // add button and logs button in the same row
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // add button
                                ElevatedButton(
                                  onPressed: () {
                                    // Add button logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        primaryColor, // Set the background color to light green
                                  ),
                                  child: Text('Add'),
                                ),

                                // logs button
                                SizedBox(
                                    width:
                                        10), // Add some spacing between the buttons
                                ElevatedButton(
                                  onPressed: () {
                                    // Logs button logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        primaryColor, // Set the background color to light green
                                  ),
                                  child: Text('Logs'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
